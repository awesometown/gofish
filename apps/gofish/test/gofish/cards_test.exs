defmodule Gofish.CardsTest do
	use ExUnit.Case, async: true
	alias Gofish.Card
	alias Gofish.Cards

	test "find_pairs returns empty lists when no cards provided" do
		{:ok, [], []} = Cards.find_pairs([])
	end

	test "find_pairs returns unmatched card when one card provided" do
		card = Card.new(1, :diamonds)
		{:ok, [card], []} = Cards.find_pairs([card])
	end

	test "three unmatched cards come back unmatched" do
		# {:ok, pid} = :dbg.tracer()
		# {:ok, _} = :dbg.p(:all, :c)
		# {:ok, _} = :dbg.tpl(Cards, :_, :x)
		cards = [Card.new(3, :spades), Card.new(2, :spades), Card.new(1, :diamonds)]
		{:ok, cards, []} = Cards.find_pairs(cards)
		assert 3 == length(cards)
		# :dbg.stop_clear()
	end

	test "two unmatched cards come back unmatched" do
		card1 = Card.new(1, :diamonds)
		card2 = Card.new(2, :diamonds)
		cards = [card1, card2]
		{:ok, cards, []} = Cards.find_pairs(cards)
	end

	test "matched cards removed from remaining cards" do
		cards = [Card.new(1, :diamonds), Card.new(1, :spades)]
		{:ok, [], _} = Cards.find_pairs(cards)
	end

	test "matched cards added to pairs" do
		cards = [Card.new(1, :diamonds), Card.new(1, :spades)]
		{:ok, _, [pair]} = Cards.find_pairs(cards)
	end

	test "multiple pairs matched" do
		cards = [
			Card.new(1, :diamonds),
			Card.new(2, :diamonds),
			Card.new(3, :diamonds),
			Card.new(1, :spades),
			Card.new(2, :spades)
		]
		{:ok, remaining, pairs} = Cards.find_pairs(cards)
		assert length(pairs) == 2
		assert length(remaining) == 1
		assert hd(remaining) == Card.new(3, :diamonds)
	end
end