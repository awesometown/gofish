defmodule Gofish.GameFsmTest do
	use ExUnit.Case, async: true

	alias Gofish.Card, as: Card

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
			|> ok(&Gofish.GameFsm.play(&1, 1, 2, 1))
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
					|> ok(&Gofish.GameFsm.play(&1, 1, 2, 1))
					|> Gofish.GameFsm.data
		assert hd(data.players).player_id == 2
	end

	test "current player loops after last player plays" do
		data = Gofish.GameFsm.new
					|> Gofish.GameFsm.join(1)
					|> Gofish.GameFsm.join(2)
					|> Gofish.GameFsm.start(nonmatching_deck(), 1)
					|> ok(&Gofish.GameFsm.play(&1, 1, 2, 1))
					|> ok(&Gofish.GameFsm.play(&1, 2, 1, 2))
					|> Gofish.GameFsm.data
		assert hd(data.players).player_id == 1
	end

	test "request with no match gives go_fish" do 
		{{:ok, :go_fish}, _fsm} = Gofish.GameFsm.new
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
				|> ok(&Gofish.GameFsm.play(&1, 1, 2, 1))
				|> Gofish.GameFsm.data
		assert hd(data.players).player_id == 2
	end

	test "request with match gives matched_card" do
		{{:ok, card}, _fsm} = Gofish.GameFsm.new
				|> Gofish.GameFsm.join(1)
				|> Gofish.GameFsm.join(2)
				|> Gofish.GameFsm.start([%Card{suit: :spades, rank: 1}, %Card{suit: :diamonds, rank: 1}], 1)
				|> Gofish.GameFsm.play(1, 2, 1)
	end

	test "request with match does not proceed to next player" do
		data = Gofish.GameFsm.new
				|> Gofish.GameFsm.join(1)
				|> Gofish.GameFsm.join(2)
				|> Gofish.GameFsm.start([%Card{suit: :spades, rank: 1}, %Card{suit: :diamonds, rank: 1}], 1)
				|> ok(&Gofish.GameFsm.play(&1, 1, 2, 1))
				|> Gofish.GameFsm.data
		assert hd(data.players).player_id == 1
	end

	test "request to self fails with error" do
		{response, _fsm} = Gofish.GameFsm.new
				|> Gofish.GameFsm.join(1)
				|> Gofish.GameFsm.join(2)
				|> Gofish.GameFsm.start([%Card{suit: :spades, rank: 1}, %Card{suit: :diamonds, rank: 1}], 1)
				|> Gofish.GameFsm.play(1, 1, 1)
		assert {:error, :invalid_target} == response
	end

	defp matching_deck() do
		[%Card{rank: 1, suit: :diamonds}, %Card{rank: 1, suit: :clubs}]
	end

	defp nonmatching_deck() do
		[%Card{rank: 1, suit: :spades}, %Card{rank: 2, suit: :clubs}]
	end

	defp ok(fsm, fun) do
		{{status, _result}, new_fsm} = fun.(fsm)
		assert status == :ok
		new_fsm
	end

end