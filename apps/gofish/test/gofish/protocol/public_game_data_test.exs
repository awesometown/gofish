defmodule Gofish.Protocol.PublicGameDataTest do
	use ExUnit.Case, async: true

	alias Gofish.Protocol.PublicGameData
	
	alias Gofish.Game.GameData
	alias Gofish.Game.PlayerData

	alias Gofish.Deck

	test "all players get mapped" do
		player1 = PlayerData.new(1)
		player2 = PlayerData.new(2)
		player3 = PlayerData.new(3)
		game_server_data = %Gofish.Game.GameData{
			players: [player1, player2, player3],
			deck: Deck.create(),
			face_up_cards: []
		}
		public_data = PublicGameData.build_for_player(1, :turn, game_server_data)
		assert length(public_data.players) == 3
	end

	test "remaining card count is mapped" do
		deck = Deck.create()
		game_data = GameData.new([], deck)

		public_data = PublicGameData.build_for_player(1, :turn, game_data)
		assert public_data.num_cards_remaining == 52
	end

end