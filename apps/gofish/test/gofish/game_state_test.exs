defmodule Gofish.GameStateTest do
	use ExUnit.Case, async: true
	alias Gofish.GameState
	alias Gofish.PlayerState
	alias Gofish.Card

	test "foo" do
		%Gofish.GameState{players: [1,2]}
	end

	test "advance cycles players" do
		gamestate = %GameState{players: [1,2,3]}
		updated = GameState.advance_players(gamestate)
		assert updated.players == [2,3,1]
	end

	test "find_player finds player" do
		player1 = %PlayerState{player_id: 1}
		player2 = %PlayerState{player_id: 2}
		player3 = %PlayerState{player_id: 3}
		gamestate = %GameState{players: [player1, player2, player3]}
		found = GameState.find_player(gamestate, 2)
		assert found == player2
	end

	test "update_player updates player" do
		player1 = %PlayerState{player_id: 1}
		player2 = %PlayerState{player_id: 2}
		player3 = %PlayerState{player_id: 3}
		new_player2 = %PlayerState{player_id: 2, hand: [%Gofish.Card{}]}
		gamestate = %GameState{players: [player1, player2, player3]}
		%{players: [^player1, player2, ^player3]} = GameState.update_player(gamestate, new_player2)
		assert length(player2.hand) == 1
	end

	test "update_player gives error when no player matches" do
		player1 = %PlayerState{player_id: 1}
		player2 = %PlayerState{player_id: 2}
		badplayer = %PlayerState{player_id: 3, hand: [%Gofish.Card{}]}
		gamestate = %GameState{players: [player1, player2]}
		{:error, :invalid_player_specified} = GameState.update_player(gamestate, badplayer)
	end

	test "game not over when cards remain in deck" do
		player1 = %PlayerState{player_id: 1}
		player2 = %PlayerState{player_id: 2}
		deck = [Card.new(1, :diamonds)]
		gamestate = GameState.new([player1, player2], deck)
		assert false == GameState.is_game_over?(gamestate)
	end

	test "game not over when players have cards" do
		player1 = %PlayerState{player_id: 1} |> PlayerState.deal_card(Card.new(1, :spades))
		player2 = %PlayerState{player_id: 2} |> PlayerState.deal_card(Card.new(1, :diamonds))
		gamestate = GameState.new([player1, player2], [])
		assert false == GameState.is_game_over?(gamestate)
	end

	test "game over when no cards left" do
		player1 = %PlayerState{player_id: 1}
		player2 = %PlayerState{player_id: 2}
		gamestate = GameState.new([player1, player2], [])
		assert true == GameState.is_game_over?(gamestate)
	end
end