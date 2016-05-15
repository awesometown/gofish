defmodule Gofish.DeckTest do
	use ExUnit.Case, async: true

	test "new deck has 52 cards" do
		deck = Gofish.Deck.create
		assert length(deck) == 52
	end

	test "shuffle doesn't explode" do
		# Hard to test much else here since we can't assert what "shuffled" looks like
		deck = Gofish.Deck.create
		Gofish.Deck.shuffle(deck)
	end
end