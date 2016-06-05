defmodule Gofish.Protocol.PublicPlayerDataTest do
	use ExUnit.Case, async: true

	alias Gofish.Protocol.PublicPlayerData
	alias Gofish.Card

	test "create public data from player data" do
		player = %Gofish.Game.PlayerData {
			player_id: 12,
			hand: [Card.new(1, :diamonds), Card.new(2, :spades)],
			pairs: [
				{Card.new(3, :spades), Card.new(3, :clubs)},
				{Card.new(4, :spades), Card.new(4, :clubs)}
			]
		}

		public_data = PublicPlayerData.new_from_player(player)
		assert public_data.player_id == 12
		assert public_data.card_count == 2
		assert public_data.pair_count == 2
	end

end