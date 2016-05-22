defmodule Gofish.PlayerStateTest do
	use ExUnit.Case, async: true

	alias Gofish.Card
	alias Gofish.PlayerState

	test "deal_card adds card to player hand" do
		player = PlayerState.new(1)
		player = PlayerState.deal_card(player, Card.new(1, :diamonds))
		assert length(player.hand) == 1
	end
end