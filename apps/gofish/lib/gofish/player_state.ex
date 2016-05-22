defmodule Gofish.PlayerState do
	defstruct player_id: nil, hand: [], cards: nil, pairs: []

	def new(id) do
		%Gofish.PlayerState{player_id: id}
	end

	def deal_card(player, card) do
		%Gofish.PlayerState{player | hand: [card | player.hand]}
	end
end