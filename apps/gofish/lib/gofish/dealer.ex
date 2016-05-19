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
		{rest_cards, %Gofish.PlayerState{player | hand: [card | player.hand]}}
	end

	def exchange_cards(source_player, target_player, source_card, matching_card) do
		source_player_hand = List.delete(source_player.hand, source_card)
		target_player_hand = List.delete(target_player.hand, matching_card)
		source_player = %{source_player | hand: source_player_hand, pairs: source_player.pairs ++ [{source_card, matching_card}]}
		target_player = %{target_player | hand: target_player_hand}
		{:ok, source_player, target_player}
	end
end