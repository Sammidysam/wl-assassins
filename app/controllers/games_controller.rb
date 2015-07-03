class GamesController < ApplicationController
	include TerminationAt

	before_action :set_game, only: [:show, :edit, :update, :destroy, :events, :team_fees, :add, :remove, :add_all, :remove_all, :start, :eligibility, :monitor]

	load_and_authorize_resource

	# GET /games
	# GET /games.json
	def index
		@games = Game.all.select { |game| can? :read, game }
	end

	# GET /games/1
	# GET /games/1.json
	def show
		if @game.completed?
			@terminators = @game.teams.select { |team| team.terminators?(@game.id) }
			non_query_ids = @terminators.map(&:id)
			@winner = @game.participations.find_by(place: 1).team
			participations = @game.participations.where.not(place: 1).order(:place)
			non_query_ids << @winner.id
			teams = @game.teams.where.not(id: non_query_ids)
			@places = participations.map { |p| p.place }
			@ordered_teams = []
			participations.each do |p|
				@ordered_teams << teams.find { |t| t.id == p.team_id }
			end
		elsif @game.in_progress?
			@order_hash = placement_order_hash(@game)
		end
	end

	# GET /games/new
	def new
		@game = Game.new
	end

	# GET /games/1/edit
	def edit
	end

	# POST /games
	# POST /games.json
	def create
		@game = Game.new(game_params)

		respond_to do |format|
			if @game.save
				format.html { redirect_to @game, notice: "Game was successfully created." }
				format.json { render action: "show", status: :created, location: @game }
			else
				format.html { render action: "new" }
				format.json { render json: @game.errors, status: :unprocessable_entity }
			end
		end
	end

	# PATCH/PUT /games/1
	# PATCH/PUT /games/1.json
	def update
		respond_to do |format|
			if @game.update(game_params)
				format.html { redirect_to @game, notice: "Game was successfully updated." }
				format.json { head :no_content }
			else
				format.html { render action: "edit" }
				format.json { render json: @game.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /games/1
	# DELETE /games/1.json
	def destroy
		@game.destroy
		respond_to do |format|
			format.html { redirect_to games_url }
			format.json { head :no_content }
		end
	end

	# GET /games/1/events
	def events
		@confirmed_kills = @game.kills.where(confirmed: true).order(:confirmed_at)
		@confirmed_neutralizations = @game.neutralizations.where(confirmed: true).order(:start)
		@eliminated_teams = @game.eliminated_teams.sort_by { |team| team.eliminated_at(@game.id) }
	end

	# GET /games/1/team_fees
	def team_fees
		@participations = @game.participations.where(terminators: false)

		unpaid_participations = @participations.where("paid_amount < ?", @game.team_fee).order(:team_id)
		unpaid_teams = Team.where(id: unpaid_participations.map { |participation| participation.team_id }).order(:id)

		@unpaid = unpaid_participations.zip(unpaid_teams)

		paid_participations = @participations.where("paid_amount >= ?", @game.team_fee).order(:team_id)
		paid_teams = Team.where(id: paid_participations.map { |participation| participation.team_id }).order(:id)

		@paid = paid_participations.zip(paid_teams)
	end

	# POST /games/1/add
	def add
		unless team = Team.find_by(name: params[:name])
			redirect_to @game, alert: "#{params[:name]} is not a team!"
		else
			participation = Participation.new
			participation.team_id = team.id
			participation.game_id = @game.id
			participation.paid_amount = 0.0

			redirect_to @game, alert: (participation.save ? nil : "Could not add to game!")
		end
	end

	# POST /games/1/remove
	def remove
		participation = @game.participations.find { |inner_participation| inner_participation.team.name == params[:name] }

		redirect_to @game, alert: (participation.destroy ? nil : "Could not remove from game!")
	end

	# POST /games/1/add_all
	def add_all
		teams = Team.not_in_game(@game)

		errors = false

		teams.each do |team|
			participation = Participation.new
			participation.team_id = team.id
			participation.game_id = @game.id
			participation.paid_amount = 0.0

			errors = true unless participation.save
		end

		redirect_to @game, alert: (errors ? "Could not add all teams!" : nil)
	end

	# POST /games/1/remove_all
	def remove_all
		errors = false

		@game.participations.each do |participation|
			errors = true unless participation.destroy
		end

		redirect_to @game, alert: (errors ? "Could not remove all teams!" : nil)
	end

	# POST /games/1/start
	def start
		# Check that all team members are valid and eligible.
		unless (bad_users = @game.users.select { |user| !user.valid? || !user.eligible? }.map { |user| "#{user.name} on team #{user.team.name}" }).empty?
			redirect_to @game, alert: "Not all team members are valid or eligible!  Bad users: #{bad_users.to_sentence}."
		else
			@game.in_progress = true
			@game.started_at = DateTime.now
			@game.team_fee = params[:team_fee]

			if @game.save
				# Set contracts.
				contract_teams = @game.teams.select { |team| !team.terminators? }.shuffle

				errors = false

				contract_teams.each_with_index do |team, index|
					contract = Contract.new
					contract.participation_id = team.participation.id
					contract.target_id = contract_teams[index + 1 < contract_teams.count ? index + 1 : 0].id
					contract.start = DateTime.now

					errors = true unless contract.save
				end

				# Set the termination time.
				contract_teams.each do |team|
					participation = team.participation
					participation.termination_at = next_termination_at(@game.remaining_teams.count)

					errors = true unless participation.save
				end

				# Create jobs for team auto-termination.
				contract_teams.each { |team| team.autoterminate }

				redirect_to @game, alert: (errors ? "Could not set up game!" : nil)
			else
				redirect_to @game, alert: "Could not start game!"
			end
		end
	end

	# GET /games/1/eligibility
	# this would be good to utilize Ajax instead of server-side
	def eligibility
		users = @game.users
		invalid_users = users.select { |u| !u.valid? }
		invalid_users.map! { |u| "#{u.name} on team #{u.team.name}" }
		ineligible_users = users.select { |u| !u.eligible? }
		ineligible_users.map! { |u| "#{u.name} on team #{u.team.name}" }

		if !invalid_users.empty? || !ineligible_users.empty?
			redirect_to @game, alert: "Invalid users: #{invalid_users.empty? ? "None" : invalid_users.to_sentence}<br />Ineligible users: #{ineligible_users.empty? ? "None" : ineligible_users.to_sentence}".html_safe
		else
			redirect_to @game, notice: "All users can play this year!"
		end
	end

	# GET /games/1/manage
	def monitor
		if @game.in_progress?
			@contract_order_teams = view_context.contract_order_teams(@game)
			@eliminated_teams = @game.eliminated_teams.sort_by { |team| team.eliminated_at }
		else
			redirect_to @game
		end
    end

	private
	# Use callbacks to share common setup or constraints between actions.
	def set_game
		@game = Game.find(params[:id])
	end

	# Never trust parameters from the scary internet, only allow the white list through.
	def game_params
		params.require(:game).permit(:name, :in_progress, :started_at, :ended_at, :team_fee)
	end

	def in_game_placement_sort(x, y, game_id, top_four = false)
		x_alive = !x.eliminated?(game_id)
		y_alive = !y.eliminated?(game_id)

        if x_alive == y_alive
			if top_four && !x_alive && !y_alive
				y.eliminated_at(game_id) <=> x.eliminated_at(game_id)
			else
				y.points(game_id) <=> x.points(game_id)
			end
        else
           x_alive ? -1 : 1
        end
    end

    # Returns an order hash for the game in-progress.
	def placement_order_hash(game)
		sortable_teams = Team.where(id: game.participations.where(terminators: false).map(&:team_id))
		sortable_teams = sortable_teams.sort { |x, y| in_game_placement_sort(x, y, game.id) }
		sortable_teams[0, 4] = sortable_teams[0, 4].sort { |x, y| in_game_placement_sort(x, y, game.id, true) }

		# The hash will be of format:
        #   key: place (e.g. 3)
        #   value: array of teams of that place
        # For example:
        #   { 2 => [team id 5], 3 => [team id 7, team id 15] }
        order_hash = {}

        sortable_teams.each_with_index do |team, index|
            next if order_hash.values.flatten.map { |inner_team| inner_team.id }.include?(team.id)

			last_key = order_hash.keys.sort.last
			current_place = last_key ? last_key + order_hash[last_key].count : 1
            teams = [team]

            # Check if this team is tied with any of the next teams.
			if current_place > 4
				while sortable_teams[index + 1]
					if in_game_placement_sort(team, sortable_teams[index + 1], game.id) == 0
						teams << sortable_teams[index + 1]
					else
						break
					end

					index += 1
				end
			end

            # Add to the hash.
            new_item = { current_place => teams }
            order_hash.merge! new_item
        end

		order_hash
	end
end
