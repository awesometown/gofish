defmodule Gofish.PlayerState do
	defstruct player_id: nil, hand: [], pairs: []

	def new(id) do
		%Gofish.PlayerState{player_id: id}
	end

	def new(id, hand) do
		%Gofish.PlayerState{player_id: id, hand: hand}
	end

	def deal_card(player, card) do
		%Gofish.PlayerState{player | hand: [card | player.hand]}
	end
end