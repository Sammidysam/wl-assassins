class IndexesForForeignKeys < ActiveRecord::Migration
	def change
		add_index :contracts, :participation_id, name: "contract_participation_index"
		add_index :contracts, :target_id, name: "contract_target_index"

		add_index :kills, :game_id, name: "kill_game_index"
		add_index :kills, :killer_id, name: "kill_killer_index"
		add_index :kills, :target_id, name: "kill_target_index"

		add_index :memberships, :user_id, name: "membership_user_index"
		add_index :memberships, :team_id, name: "membership_team_index"

		add_index :neutralizations, :killer_id, name: "neutralization_killer_index"
		add_index :neutralizations, :target_id, name: "neutralization_target_index"
		add_index :neutralizations, :game_id, name: "neutralization_game_index"

		add_index :participations, :team_id, name: "participation_team_index"
		add_index :participations, :game_id, name: "participation_game_index"
	end
end
