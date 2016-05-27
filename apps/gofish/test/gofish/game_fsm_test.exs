defmodule Gofish.GameFsmTest do
	use ExUnit.Case, async: true

	alias Gofish.Card
	alias Gofish.GameState
	alias Gofish.GameFsm

	@moduletag :capture_log

	test "starting state has no players" do
		data = Gofish.GameFsm.new
				|> Gofish.GameFsm.data
		assert data.players == []
	end

	test "state contains player after join" do
		data = Gofish.GameFsm.new
					|> Gofish.GameFsm.join(1)
					|> Gofish.GameFsm.data
		assert hd(data.players).player_id == 1
	end

	test "state contains two players after two joins" do
		data = Gofish.GameFsm.new
					|> Gofish.GameFsm.join(1)
					|> Gofish.GameFsm.join(2)
					|> Gofish.GameFsm.data
		assert length(data.players) == 2
	end

	test "players have five cards after start" do
		data = Gofish.GameFsm.new
					|> Gofish.GameFsm.join(1)
					|> Gofish.GameFsm.join(2)
					|> Gofish.GameFsm.start()
					|> Gofish.GameFsm.data
		Enum.each(data.players, fn(p) -> assert length(p.hand) == 5 end)
	end

	test "player ones turn after start" do
		data = Gofish.GameFsm.new
					|> Gofish.GameFsm.join(1)
					|> Gofish.GameFsm.join(2)
					|> Gofish.GameFsm.start()
					|> Gofish.GameFsm.data
		assert hd(data.players).player_id == 1
	end

	test "correct player can play" do
		Gofish.GameFsm.new
			|> Gofish.GameFsm.join(1)
			|> Gofish.GameFsm.join(2)
			|> Gofish.GameFsm.start(nonmatching_deck(), 1)
			|> gf(&Gofish.GameFsm.play(&1, 1, 2, 1))
	end

	test "incorrect player cannot play" do
		{:not_your_turn, _} = Gofish.GameFsm.new
									|> Gofish.GameFsm.join(1)
									|> Gofish.GameFsm.join(2)
									|> Gofish.GameFsm.start()
									|> Gofish.GameFsm.play(2, 1, "foo")
	end

	test "play advances current_player" do
		data = Gofish.GameFsm.new
					|> Gofish.GameFsm.join(1)
					|> Gofish.GameFsm.join(2)
					|> Gofish.GameFsm.start(nonmatching_deck(), 1)
					|> gf(&Gofish.GameFsm.play(&1, 1, 2, 1))
					|> Gofish.GameFsm.data
		assert hd(data.players).player_id == 2
	end

	test "current player loops after last player plays" do
		data = Gofish.GameFsm.new
					|> Gofish.GameFsm.join(1)
					|> Gofish.GameFsm.join(2)
					|> Gofish.GameFsm.start(nonmatching_deck(), 1)
					|> gf(&Gofish.GameFsm.play(&1, 1, 2, 1))
					|> gf(&Gofish.GameFsm.play(&1, 2, 1, 2))
					|> Gofish.GameFsm.data
		assert hd(data.players).player_id == 1
	end

	test "request with no match gives go_fish" do 
		{:go_fish, _fsm} = Gofish.GameFsm.new
				|> Gofish.GameFsm.join(1)
				|> Gofish.GameFsm.join(2)
				|> Gofish.GameFsm.start([%Card{suit: :spades, rank: 1}, %Card{suit: :spades, rank: 2}], 1)
				|> Gofish.GameFsm.play(1, 2, 1)
	end

	test "request with no match proceeds to next player" do
		data = Gofish.GameFsm.new
				|> Gofish.GameFsm.join(1)
				|> Gofish.GameFsm.join(2)
				|> Gofish.GameFsm.start([%Card{suit: :spades, rank: 1}, %Card{suit: :spades, rank: 2}], 1)
				|> gf(&Gofish.GameFsm.play(&1, 1, 2, 1))
				|> Gofish.GameFsm.data
		assert hd(data.players).player_id == 2
	end

	test "request with match does not proceed to next player" do
		data = Gofish.GameFsm.new
				|> Gofish.GameFsm.join(1)
				|> Gofish.GameFsm.join(2)
				|> Gofish.GameFsm.start([%Card{suit: :spades, rank: 1}, %Card{suit: :diamonds, rank: 1}], 1)
				|> match(&Gofish.GameFsm.play(&1, 1, 2, 1))
				|> Gofish.GameFsm.data
		assert hd(data.players).player_id == 1
	end

	test "request with match returns matching cards" do
		source_card = %Card{suit: :spades, rank: 1}
		target_card = %Card{suit: :diamonds, rank: 1}
		Gofish.GameFsm.new
				|> Gofish.GameFsm.join(1)
				|> Gofish.GameFsm.join(2)
				|> Gofish.GameFsm.start([source_card, target_card], 1)
				|> match(&Gofish.GameFsm.play(&1, 1, 2, 1), source_card, target_card)
	end

	test "request with match updates active players pairs" do
		source_card = %Card{suit: :spades, rank: 1}
		target_card = %Card{suit: :diamonds, rank: 1}
		data = Gofish.GameFsm.new
				|> Gofish.GameFsm.join(1)
				|> Gofish.GameFsm.join(2)
				|> Gofish.GameFsm.start([source_card, target_card], 1)
				|> match(&Gofish.GameFsm.play(&1, 1, 2, 1), source_card, target_card)
				|> Gofish.GameFsm.data
		player1 = GameState.find_player(data, 1)
		assert length(player1.pairs) == 1
		pair = hd(player1.pairs)
		assert pair == {source_card, target_card}
	end

	test "request to self fails with error" do
		{response, _fsm} = Gofish.GameFsm.new
				|> Gofish.GameFsm.join(1)
				|> Gofish.GameFsm.join(2)
				|> Gofish.GameFsm.start([%Card{suit: :spades, rank: 1}, %Card{suit: :diamonds, rank: 1}], 1)
				|> Gofish.GameFsm.play(1, 1, 1)
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
						|> GameFsm.join(1)
						|> GameFsm.join(2)
						|> GameFsm.start(deck, 2)
						|> gf(&GameFsm.play(&1, 1, 2, 2))
						|> GameFsm.data
		player1 = GameState.find_player(gamestate, 1)
		assert length(player1.hand) == 3
	end

	test "game ends when all cards played" do
		deck = [
			Card.new(1, :diamonds),
			Card.new(1, :clubs)]
		state = GameFsm.new
					|> GameFsm.join(1)
					|> GameFsm.join(2)
					|> GameFsm.start(deck, 1)
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
					|> GameFsm.join(1)
					|> GameFsm.join(2)
					|> GameFsm.start(deck, 2)
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
					|> GameFsm.join(1)
					|> GameFsm.join(2)
					|> GameFsm.start(deck, 1)
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
					|> GameFsm.join(1)
					|> GameFsm.join(2)
					|> GameFsm.start(deck, 1)
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
		gamestate = Gofish.GameFsm.new
						|> Gofish.GameFsm.join(1)
						|> Gofish.GameFsm.join(2)
						|> Gofish.GameFsm.start(deck, 3)
						|> match(&Gofish.GameFsm.play(&1, 1, 2, 1))
						|> gf(&Gofish.GameFsm.play(&1, 1, 2, 2))
						|> match(&Gofish.GameFsm.play(&1, 2, 1, 3))
						|> gf(&Gofish.GameFsm.play(&1, 2, 1, 5))
						|> Gofish.GameFsm.data
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