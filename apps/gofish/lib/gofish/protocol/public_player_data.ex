defmodule Gofish.Protocol.PublicPlayerData do
	defstruct player_id: nil, card_count: 0, pair_count: 0

	def new_from_player(player) do
		%Gofish.Protocol.PublicPlayerData{
			player_id: player.player_id,
			card_count: length(player.hand),
			pair_count: length(player.pairs)
		}
	end
end