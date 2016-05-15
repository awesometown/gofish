defmodule Gofish.Dealer do
	
	def deal(cards, players, 0) do
		{cards, players}
	end

	def deal(cards, players, num_cards) do
		{rest_cards, players} = deal_round(cards, players)
		deal(rest_cards, players, num_cards - 1)
	end

	def deal_round(cards, [next_player | rest_players]) do
		{rest_cards, player} = deal_card(cards, next_player)
		{rest_cards, dealt_players} = deal_round(rest_cards, rest_players)
		{rest_cards, [player] ++ dealt_players}
	end

	def deal_round(cards, []) do
		{cards, []}
	end

	def deal_card([card | rest_cards], player) do
		{rest_cards, %Gofish.PlayerState{player | cards: [card | player.cards]}}
	end
end