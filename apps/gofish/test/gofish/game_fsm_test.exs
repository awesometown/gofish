defmodule Gofish.GameFsmTest do
	use ExUnit.Case, async: true

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
		Enum.each(data.players, fn(p) -> assert length(p.cards) == 5 end)
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
			|> Gofish.GameFsm.start()
			|> ok(&Gofish.GameFsm.play(&1, 1, "foo"))
	end

	test "incorrect player cannot play" do
		{:not_your_turn, _} = Gofish.GameFsm.new
									|> Gofish.GameFsm.join(1)
									|> Gofish.GameFsm.join(2)
									|> Gofish.GameFsm.start()
									|> Gofish.GameFsm.play(2, "foo")
	end

	test "play advances current_player" do
		data = Gofish.GameFsm.new
					|> Gofish.GameFsm.join(1)
					|> Gofish.GameFsm.join(2)
					|> Gofish.GameFsm.start()
					|> ok(&Gofish.GameFsm.play(&1, 1, "foo"))
					|> Gofish.GameFsm.data
		assert hd(data.players).player_id == 2
	end

	test "current player loops after last player plays" do
		data = Gofish.GameFsm.new
					|> Gofish.GameFsm.join(1)
					|> Gofish.GameFsm.join(2)
					|> Gofish.GameFsm.start()
					|> ok(&Gofish.GameFsm.play(&1, 1, "foo"))
					|> ok(&Gofish.GameFsm.play(&1, 2, "foo"))
					|> Gofish.GameFsm.data
		assert hd(data.players).player_id == 1
	end

	def ok(fsm, fun) do
		{response, new_fsm} = fun.(fsm)
		assert response == :ok
		new_fsm
	end

end