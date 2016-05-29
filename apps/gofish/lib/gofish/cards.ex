defmodule Gofish.Cards do
	
	def find_pairs([]) do
		{:ok, [], []}
	end

	def find_pairs([card]) do
		{:ok, [], [card]}
	end

	def find_pairs([card|rest]) do
		{:ok, pairs, remaining_cards} = find_pair(rest, card)
		{:ok, other_pairs, remaining_cards} = find_pairs(remaining_cards)
		{:ok, pairs ++ other_pairs, remaining_cards}
	end

	def find_pair(cards, card_to_match) do
		matched_card = Enum.find(cards, fn(card) -> card.rank == card_to_match.rank end)
		case matched_card do
			nil -> {:ok, [], cards}
			_ -> {:ok, [{card_to_match, matched_card}], List.delete(cards, matched_card)}
		end
	end
end