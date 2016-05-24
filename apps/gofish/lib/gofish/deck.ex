defmodule Gofish.Deck do
	def create do
		for suit <- [:spades, :diamonds, :clubs, :hearts], rank <- 1..13 do
			%Gofish.Card{suit: suit, rank: rank}
		end
	end

	def create_shuffled do
		shuffle(create())
	end

	def shuffle(cards) do
		Enum.shuffle cards
	end
end