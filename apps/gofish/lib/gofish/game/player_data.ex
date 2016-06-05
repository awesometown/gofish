defmodule Gofish.Game.PlayerData do
	defstruct player_id: nil, hand: [], pairs: []

	alias Gofish.Game.PlayerData

	def new(id) do
		%PlayerData{player_id: id}
	end

	def new(id, hand) do
		%PlayerData{player_id: id, hand: hand}
	end

	def deal_card(player, card) do
		%PlayerData{player | hand: [card | player.hand]}
	end

	def update(player, hand, pairs) do
		%PlayerData{player | hand: hand, pairs: pairs}
	end
end