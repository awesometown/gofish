defmodule Gofish.Cards do
	
	import Logger

	def find_pairs([]) do
		{:ok, [], []}
	end

	def find_pairs([card]) do
		{:ok, [card], []}
	end

	def find_pairs([first | rest] = cards) do
		matched_card = Enum.find(rest, fn(c) -> c.rank == first.rank end)
		case matched_card do
			nil -> 
				{:ok, cards, p} = find_pairs(rest)
				{:ok, [first] ++ cards, p}
			_ -> 
				rest = List.delete(rest, matched_card)
				{:ok, cards, p} = find_pairs(rest)
				{:ok, cards, [{first, matched_card}] ++ p}
 		end
	end
end