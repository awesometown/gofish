defmodule Gofish.DealerTest do
	use ExUnit.Case, async: true

	test "deal_card to player gives card" do
		deck = Gofish.Deck.create
		player = Gofish.PlayerState.new(1)
		{rest_cards, player} = Gofish.Dealer.deal_card(deck, player)
		assert length(rest_cards) == 51
		assert length(player.cards) == 1
	end

	test "deal_round to players gives each player card" do
		deck = Gofish.Deck.create
		player1 = Gofish.PlayerState.new(1)
		player2 = Gofish.PlayerState.new(2)
		{_rest_cards, players} = Gofish.Dealer.deal_round(deck, [player1, player2])
		Enum.each(players, fn(p) -> assert length(p.cards) == 1 end)
	end

	test "deal three cards" do
		deck = Gofish.Deck.create
		player1 = Gofish.PlayerState.new(1)
		player2 = Gofish.PlayerState.new(2)
		{_rest_cards, players} = Gofish.Dealer.deal(deck, [player1, player2], 3)
		Enum.each(players, fn(p) -> assert length(p.cards) == 3 end)
	end

end