class GamesController < ApplicationController
	before_action :set_game, only: [:show, :edit, :update, :destroy, :add, :remove, :add_all, :remove_all, :start]

	load_and_authorize_resource

	# GET /games
	# GET /games.json
	def index
		@games = Game.all.select { |game| can? :read, game }
	end

	# GET /games/1
	# GET /games/1.json
	def show
		@confirmed_kills = @game.kills.where(confirmed: true)
		@confirmed_neutralizations = @game.neutralizations.where(confirmed: true)
		@contract_order_teams = view_context.contract_order_teams(@game) if @game.in_progress
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
		# Check that all team members are valid.
		unless (bad_users = @game.users.select { |user| !user.valid? }.map { |user| "#{user.name} on team #{user.team.name}" }).empty?
			redirect_to @game, alert: "Not all team members are valid!  Bad users: #{bad_users.to_sentence}."
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
					participation.termination_at = DateTime.now + (@game.teams.select { |team| !team.terminators? && !team.eliminated? }.count > 4 ? 5 : 4).days

					errors = true unless participation.save
				end
				
				redirect_to @game, alert: (errors ? "Could not set up game!" : nil)
			else
				redirect_to @game, alert: "Could not start game!"
			end
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
end
