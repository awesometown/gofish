defmodule Gofish.PlayerMap do
	defstruct pid_to_id: %{}, players: []

	import Logger

	alias Gofish.PlayerMap
	alias Gofish.Game.PlayerData

	def new() do
		new([])
	end

	def new([]) do
		%PlayerMap{}
	end

	def new([p|rest]) do
		pm = new(rest)
		add(pm, p)
	end

	def add(%{pid_to_id: p2i, players: pl} = player_map, pid) do
		next_id = length(pl) + 1
		player_data = PlayerData.new(next_id)
		%{player_map | pid_to_id: Map.put(p2i, pid, next_id), players: pl ++ [player_data]}
	end

	def get_id(%{pid_to_id: p2i}, pid) do
		debug("Looking up #{inspect(pid)} in #{inspect(p2i)}")
		Map.get(p2i, pid)
	end
end