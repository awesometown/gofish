defmodule Gofish.PlayerMapTest do
	use ExUnit.Case, async: true
	alias Gofish.PlayerMap

	test "first player gets id 1" do
		pm = PlayerMap.new()
		pid = pid(255)
		pm = PlayerMap.add(pm, pid)
		1 = PlayerMap.get_id(pm, pid)
	end

	defp pid(p) do
		:c.pid(0, p, 0)
	end
end