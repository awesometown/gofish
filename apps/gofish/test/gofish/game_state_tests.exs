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
end