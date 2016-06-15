defmodule Gofish.Game.GameFsmTest do
	use ExUnit.Case, async: true

	alias Gofish.Card
	alias Gofish.Game.GameData
	alias Gofish.Game.GameFsm
	alias Gofish.Game.PlayerData

	@moduletag :capture_log

	test "game cannot start with zero players" do
		{result, _} = GameFsm.new |> GameFsm.start([])
		assert result == {:error, :insufficient_players}
	end

	test "game cannot start with one player" do
		{result, _} = GameFsm.new
			|> GameFsm.start([PlayerData.new(1)])
		assert result == {:error, :insufficient_players}
	end

	test "two players get added to gamestate" do
		data = GameFsm.new
				|> GameFsm.start(two_players())
				|> GameFsm.data
		assert length(data.players) == 2
	end

	test "players have five cards after start" do
		data = GameFsm.new
				|> GameFsm.start(two_players())
				|> GameFsm.data
		Enum.each(data.players, fn(p) -> assert length(p.hand) == 5 end)
	end

	test "player ones turn after start" do
		data = GameFsm.new
				|> GameFsm.start(two_players())
				|> GameFsm.data
		assert hd(data.players).player_id == 1
	end

	test "correct player can play" do
		GameFsm.new
			|> GameFsm.start(two_players(), nonmatching_deck(), 1)
			|> gf(&GameFsm.play(&1, 1, 2, 1))
	end

	test "incorrect player cannot play" do
		{:not_your_turn, _} = GameFsm.new
									|> GameFsm.start(two_players())
									|> GameFsm.play(2, 1, "foo")
	end

	test "current player loops after last player plays" do
		data = GameFsm.new
					|> GameFsm.start(two_players(), nonmatching_deck(), 1)
					|> gf(&GameFsm.play(&1, 1, 2, 1))
					|> gf(&GameFsm.play(&1, 2, 1, 2))
					|> GameFsm.data
		assert hd(data.players).player_id == 1
	end

	test "request with no match gives go_fish" do 
		{:go_fish, _fsm} = GameFsm.new
				|> GameFsm.start(two_players(), [%Card{suit: :spades, rank: 1}, %Card{suit: :spades, rank: 2}], 1)
				|> GameFsm.play(1, 2, 1)
	end

	test "request with match returns matching cards" do
		source_card = %Card{suit: :spades, rank: 1}
		target_card = %Card{suit: :diamonds, rank: 1}
		GameFsm.new
				|> GameFsm.start(two_players(), [source_card, target_card], 1)
				|> match(&GameFsm.play(&1, 1, 2, 1), source_card, target_card)
	end

	test "request with match updates active players pairs" do
		source_card = %Card{suit: :spades, rank: 1}
		target_card = %Card{suit: :diamonds, rank: 1}
		data = GameFsm.new
				|> GameFsm.start(two_players(), [source_card, target_card], 1)
				|> match(&GameFsm.play(&1, 1, 2, 1), source_card, target_card)
				|> GameFsm.data
		player1 = GameData.find_player(data, 1)
		assert length(player1.pairs) == 1
		pair = hd(player1.pairs)
		assert pair == {source_card, target_card}
	end

	test "request to self fails with error" do
		{response, _fsm} = GameFsm.new
				|> GameFsm.start(two_players(), [%Card{suit: :spades, rank: 1}, %Card{suit: :diamonds, rank: 1}], 1)
				|> GameFsm.play(1, 1, 1)
		assert {:error, :invalid_target} == response
	end

	test "go_fish gives player new card" do
		deck = [
			Card.new(1, :diamonds),
			Card.new(1, :clubs),
			Card.new(2, :spades),
			Card.new(3, :clubs),
			Card.new(3, :spades),
			Card.new(5, :hearts)]

		gamestate = GameFsm.new
						|> GameFsm.start(two_players(), deck, 2)
						|> gf(&GameFsm.play(&1, 1, 2, 2))
						|> GameFsm.data
		player1 = GameData.find_player(gamestate, 1)
		assert length(player1.hand) == 3
	end

	test "go_fish finding matching card adds pair for player" do
		deck = [
			Card.new(1, :diamonds),
			Card.new(2, :spades),
			Card.new(1, :clubs)]

		gamestate = GameFsm.new
						|> GameFsm.start(two_players(), deck, 1)
						|> gf(&GameFsm.play(&1, 1, 2, 1))
						|> GameFsm.data
		player1 = GameData.find_player(gamestate, 1)
		assert length(player1.pairs) == 1
	end

	test "go_fish finding matching card does not advance players" do
		deck = [
			Card.new(1, :diamonds),
			Card.new(2, :spades),
			Card.new(1, :clubs)]

		gamestate = GameFsm.new
						|> GameFsm.start(two_players(), deck, 1)
						|> gf(&GameFsm.play(&1, 1, 2, 1))
						|> GameFsm.data
		assert 1 = hd(gamestate.players).player_id	
	end


	test "go_fish not finding match advances players" do
		deck = [
			Card.new(1, :diamonds),
			Card.new(2, :spades),
			Card.new(3, :clubs)]

		gamestate = GameFsm.new
						|> GameFsm.start(two_players(), deck, 1)
						|> gf(&GameFsm.play(&1, 1, 2, 1))
						|> GameFsm.data
		assert 2 == hd(gamestate.players).player_id
	end

	test "fished card is removed from deck" do
		deck = [
			Card.new(1, :diamonds),
			Card.new(2, :spades),
			Card.new(1, :clubs),
			Card.new(5, :clubs)]

		gamestate = GameFsm.new
						|> GameFsm.start(two_players(), deck, 1)
						|> gf(&GameFsm.play(&1, 1, 2, 1))
						|> GameFsm.data
		assert length(gamestate.deck) == 1
	end

	test "game ends when all cards played" do
		deck = [
			Card.new(1, :diamonds),
			Card.new(1, :clubs)]
		state = GameFsm.new
					|> GameFsm.start(two_players(), deck, 1)
					|> match(&GameFsm.play(&1, 1, 2, 1))
					|> GameFsm.state
		assert :game_over == state
	end

	test "player hand not replenished when they still have cards" do
		deck = [
			Card.new(1, :diamonds),
			Card.new(1, :clubs),
			Card.new(2, :spades),
			Card.new(3, :clubs),
			Card.new(4, :spades),
			Card.new(5, :hearts),
			Card.new(6, :diamonds)]
		data = GameFsm.new
					|> GameFsm.start(two_players(), deck, 2)
					|> match(&GameFsm.play(&1, 1, 2, 1))
					|> GameFsm.data
		assert length(hd(data.players).hand) == 1
	end

	test "player hand replenished to 5 when cards available" do
		deck = [
			Card.new(1, :diamonds),
			Card.new(1, :clubs),
			Card.new(2, :spades),
			Card.new(3, :clubs),
			Card.new(4, :spades),
			Card.new(5, :hearts),
			Card.new(6, :diamonds)]
		data = GameFsm.new
					|> GameFsm.start(two_players(), deck, 1)
					|> match(&GameFsm.play(&1, 1, 2, 1))
					|> GameFsm.data
		assert length(hd(data.players).hand) == 5
	end

	test "player replenishes with all cards remaining when fewer than 5 available" do
		deck = [
			Card.new(1, :diamonds),
			Card.new(1, :clubs),
			Card.new(2, :spades)]
		data = GameFsm.new
					|> GameFsm.start(two_players(), deck, 1)
					|> match(&GameFsm.play(&1, 1, 2, 1))
					|> GameFsm.data
		assert length(hd(data.players).hand) == 1
	end

	test "play simple game" do
		deck = [
			Card.new(1, :diamonds),
			Card.new(1, :clubs),
			Card.new(2, :spades),
			Card.new(3, :clubs),
			Card.new(3, :spades),
			Card.new(5, :hearts)]
		gamestate = GameFsm.new
						|> GameFsm.start(two_players(), deck, 3)
						|> match(&GameFsm.play(&1, 1, 2, 1))
						|> gf(&GameFsm.play(&1, 1, 2, 2))
						|> match(&GameFsm.play(&1, 2, 1, 3))
						|> gf(&GameFsm.play(&1, 2, 1, 5))
						|> GameFsm.data
	end

	defp two_players() do
		[PlayerData.new(1), PlayerData.new(2)]
	end

	defp nonmatching_deck() do
		[%Card{rank: 1, suit: :spades}, %Card{rank: 2, suit: :clubs}]
	end

	defp result(fsm, fun, expected_result) do
		{result, new_fsm} = fun.(fsm)
		assert result == expected_result
		new_fsm
	end

	defp match(fsm, fun) do
		{{:match, _, _}, new_fsm} = fun.(fsm)
	 	new_fsm
	end

	defp match(fsm, fun, source_card, target_card) do
		{{:match, ^source_card, ^target_card}, new_fsm} = fun.(fsm)
		new_fsm
	end

	defp gf(fsm, fun) do
		result(fsm, fun, :go_fish)
	end

end