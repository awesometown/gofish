defmodule Gofish.PlayerDataTest do
	use ExUnit.Case, async: true

	alias Gofish.Card
	alias Gofish.Game.PlayerData

	test "deal_card adds card to player hand" do
		player = PlayerData.new(1)
		player = PlayerData.deal_card(player, Card.new(1, :diamonds))
		assert length(player.hand) == 1
	end
end