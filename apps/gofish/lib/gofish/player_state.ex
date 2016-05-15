defmodule Gofish.PlayerState do
	defstruct player_id: nil, cards: [], pairs: []

	def new(id) do
		%Gofish.PlayerState{player_id: id}
	end
end