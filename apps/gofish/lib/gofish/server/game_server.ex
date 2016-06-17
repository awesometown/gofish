defmodule Gofish.Server.GameServer do
	use GenServer

	alias Gofish.Game.GameFsm
	alias Gofish.Server.GameServerData
	alias Gofish.Server.PlayerMap

	alias Gofish.Protocol.PublicGameData

	def start_link do
		GenServer.start_link(__MODULE__, :ok, [])
	end

	def get_game_data(server) do
		GenServer.call(server, :get_data)
	end

	def join(server) do
		GenServer.call(server, :join)
	end

	def start_game(server) do
		GenServer.call(server, :start_game)
	end

	def make_play(_server, {_player, _card}) do
		:not_implemented
	end

	def stop(server) do
		GenServer.stop(server)
	end

	## Server Callbacks

	def init(:ok) do
		{:ok, %GameServerData{fsm: GameFsm.new, player_map: %PlayerMap{}}}
	end

	def handle_call(:get_data, {pid, _tag}, %{fsm: fsm, player_map: players} = game_server_data) do
		case PlayerMap.get_id(players, pid) do
			nil ->
				{:reply, {:error, :pid_not_found}, game_server_data}
			player_id ->
				{:reply, {:ok, get_data(fsm, player_id)}, game_server_data}
		end
	end

	def handle_call(:join, {pid, _tag}, %{fsm: fsm, player_map: players} = game_server_data) do
		case fsm.state do
			:waiting_for_players ->
				players = PlayerMap.add(players, pid)
				game_server_data = %{game_server_data | player_map: players}
				{:reply, {:you_are, PlayerMap.get_id(players, pid)}, game_server_data}
			_ ->
				{:reply, {:error, :invalid_state_to_join, fsm.state}, game_server_data}
		end
	end

	def handle_call(:start_game, _from, %{fsm: fsm, player_map: player_map} = game_server_data) do
		case fsm.state do
			:waiting_for_players ->
				result = GameFsm.start(fsm, player_map.players)
				case result do
					{{:error, error_code}, fsm} ->
						game_server_data = %GameServerData{game_server_data | fsm: fsm}
						{:reply, {:error, error_code}, game_server_data}
					fsm ->
						game_server_data = %GameServerData{game_server_data | fsm: fsm}
						broadcast_game_data(game_server_data)
						{:reply, :ok, game_server_data}
				end
			_ ->
				{:reply, {:error, :invalid_state_to_start, fsm.state}, game_server_data}
		end
	end

	defp get_data(fsm, for_player_id) do
		PublicGameData.build_for_player(for_player_id, fsm.state, fsm.data)
	end

	defp broadcast_game_data(%{fsm: _fsm, player_map: players}) do
		Enum.each(Map.keys(players.pid_to_id), fn(pid) -> send(pid, {:notify}) end)
	end
end