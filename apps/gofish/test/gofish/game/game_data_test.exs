defmodule Gofish.Game.GameDataTest do
	use ExUnit.Case, async: true
	alias Gofish.Game.GameData
	alias Gofish.Game.PlayerData
	alias Gofish.Card

	test "advance_players cycles players" do
		player1 = PlayerData.new(1, [Card.new(1, :diamonds)])
		player2 = PlayerData.new(2, [Card.new(2, :diamonds)])
		player3 = PlayerData.new(3, [Card.new(3, :diamonds)])
		gamestate = %GameData{players: [player1, player2, player3]}
		
		updated = GameData.advance_players(gamestate)
		assert updated.players == [player2, player3, player1]
	end

	test "advance_players skips player with no cards" do
		player1 = PlayerData.new(1, [Card.new(1, :diamonds)])
		player2 = PlayerData.new(2, [])
		player3 = PlayerData.new(3, [Card.new(3, :diamonds)])
		gamestate = %GameData{players: [player1, player2, player3]}
		
		updated = GameData.advance_players(gamestate)
		assert updated.players == [player3, player1, player2]
	end

	test "find_player finds player" do
		player1 = %PlayerData{player_id: 1}
		player2 = %PlayerData{player_id: 2}
		player3 = %PlayerData{player_id: 3}
		gamestate = %GameData{players: [player1, player2, player3]}
		found = GameData.find_player(gamestate, 2)
		assert found == player2
	end

	test "update_player updates player" do
		player1 = %PlayerData{player_id: 1}
		player2 = %PlayerData{player_id: 2}
		player3 = %PlayerData{player_id: 3}
		new_player2 = %PlayerData{player_id: 2, hand: [%Gofish.Card{}]}
		gamestate = %GameData{players: [player1, player2, player3]}
		%{players: [^player1, player2, ^player3]} = GameData.update_player(gamestate, new_player2)
		assert length(player2.hand) == 1
	end

	test "update_player gives error when no player matches" do
		player1 = %PlayerData{player_id: 1}
		player2 = %PlayerData{player_id: 2}
		badplayer = %PlayerData{player_id: 3, hand: [%Gofish.Card{}]}
		gamestate = %GameData{players: [player1, player2]}
		{:error, :invalid_player_specified} = GameData.update_player(gamestate, badplayer)
	end

	test "game not over when cards remain in deck" do
		player1 = %PlayerData{player_id: 1}
		player2 = %PlayerData{player_id: 2}
		deck = [Card.new(1, :diamonds)]
		gamestate = GameData.new([player1, player2], deck)
		assert false == GameData.is_game_over?(gamestate)
	end

	test "game not over when players have cards" do
		player1 = %PlayerData{player_id: 1} |> PlayerData.deal_card(Card.new(1, :spades))
		player2 = %PlayerData{player_id: 2} |> PlayerData.deal_card(Card.new(1, :diamonds))
		gamestate = GameData.new([player1, player2], [])
		assert false == GameData.is_game_over?(gamestate)
	end

	test "game over when no cards left" do
		player1 = %PlayerData{player_id: 1}
		player2 = %PlayerData{player_id: 2}
		gamestate = GameData.new([player1, player2], [])
		assert true == GameData.is_game_over?(gamestate)
	end
end