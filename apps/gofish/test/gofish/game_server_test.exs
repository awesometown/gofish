defmodule Gofish.GameServerTest do
	use ExUnit.Case, async: true

	alias Gofish.GameServer

	setup do
		{:ok, gameserver} = Gofish.GameServer.start_link
		{:ok, gameserver: gameserver}
	end 

	test "joined player can get state", %{gameserver: gameserver} do
		{:you_are, _} = GameServer.join(gameserver)
		{:ok, gamedata} = GameServer.get_game_data(gameserver)
	end

	test "get_game_data returns error for unknown sender", %{gameserver: gameserver} do
		assert GameServer.get_game_data(gameserver) == {:error, :pid_not_found}
	end

	test "joins return ids in increasing order", %{gameserver: gameserver} do
		{:you_are, 1} = GameServer.join(gameserver)
		{:you_are, 2} = GameServer.join(gameserver)
		{:you_are, 3} = GameServer.join(gameserver)
	end

	test "error when insufficent players", %{gameserver: gameserver} do
		{:you_are, 1} = GameServer.join(gameserver)
		result = GameServer.start_game(gameserver)
		assert result == {:error, :insufficient_players}
	end

	test "player receives notify when game started", %{gameserver: gameserver} do
		{:you_are, _} = GameServer.join(gameserver)
		{:you_are, _} = GameServer.join(gameserver)
		:ok = GameServer.start_game(gameserver)
		assert_received {:notify}
	end

end
