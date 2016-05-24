defmodule Gofish.DealerTest do
	use ExUnit.Case, async: true
	alias Gofish.Card
	alias Gofish.Dealer

	test "deal_card from deck gives card from deck" do
		deck = Gofish.Deck.create
		player = Gofish.PlayerState.new(1)
		{rest_cards, player} = Dealer.deal_card(deck, player)
		assert length(rest_cards) == 51
		assert length(player.hand) == 1
	end

	test "deal_round to players gives each player card" do
		deck = Gofish.Deck.create
		player1 = Gofish.PlayerState.new(1)
		player2 = Gofish.PlayerState.new(2)
		{_rest_cards, players} = Dealer.deal_round(deck, [player1, player2])
		Enum.each(players, fn(p) -> assert length(p.hand) == 1 end)
	end

	test "deal three cards" do
		deck = Gofish.Deck.create
		player1 = Gofish.PlayerState.new(1)
		player2 = Gofish.PlayerState.new(2)
		{_rest_cards, players} = Dealer.deal(deck, [player1, player2], 3)
		Enum.each(players, fn(p) -> assert length(p.hand) == 3 end)
	end

	test "exchange_cards" do
		source_card = %Card{rank: 1, suit: :spades}
		matching_card = %Card{rank: 1, suit: :diamonds}
		player1 = %Gofish.PlayerState{player_id: 1, hand: [source_card]}
		player2 = %Gofish.PlayerState{player_id: 2, hand: [matching_card]}
		{:ok, player1, player2} = Dealer.exchange_cards(player1, player2, source_card, matching_card)
		assert 0 == length(player1.hand)
		assert 0 == length(player2.hand)
		assert 1 == length(player1.pairs)
	end

end