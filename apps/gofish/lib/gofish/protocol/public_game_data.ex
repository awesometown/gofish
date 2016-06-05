defmodule Gofish.Protocol.PublicGameData do
	defstruct state: nil, current_player_id: 0, num_cards_remaining: 0, your_data: nil, players: []

	alias Gofish.Protocol.PublicPlayerData

	def build_for_player(requesting_player_id, fsm_state, game_data) do
		%Gofish.Protocol.PublicGameData{
			state: fsm_state,
			current_player_id: 0,
			num_cards_remaining: length(game_data.deck),
			your_data: nil,
			players: Enum.map(game_data.players, &PublicPlayerData.new_from_player/1)
		}
	end
end