defmodule Gofish.Protocol.PublicGameData do
	defstruct state: nil, current_player_id: 0, num_cards_remaining: 0, your_data: nil, players: []

	alias Gofish.Protocol.PublicGameData
	alias Gofish.Protocol.PublicPlayerData

	def build_for_player(_requesting_player_id, :waiting_for_players, game_data) do
		%PublicGameData{
			state: :waiting_for_players,
			current_player_id: 0,
			num_cards_remaining: 0,
			your_data: nil,
			players: Enum.map(game_data.players, &PublicPlayerData.new_from_player/1)
		}
	end

	def build_for_player(_requesting_player_id, fsm_state, game_data) do
		%PublicGameData{
			state: fsm_state,
			current_player_id: 0,
			num_cards_remaining: length(game_data.deck),
			your_data: nil,
			players: Enum.map(game_data.players, &PublicPlayerData.new_from_player/1)
		}
	end
end