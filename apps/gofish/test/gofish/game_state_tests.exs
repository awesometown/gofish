defmodule GoFish.GameStateTest do
	use ExUnit.Case, async: true

	test "foo" do
		%GameState{players: [1,2]}
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
		gamestate = %{GameState{players: [player1, player2, player3]}}
		found = GameState.find_player(gamestate, 2)
		assert found == player2
end