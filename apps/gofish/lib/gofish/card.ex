defmodule Gofish.Card do
	defstruct suit: :diamonds, rank: 1

	def new(rank, suit) do
		%Gofish.Card{rank: rank, suit: suit}
	end
end