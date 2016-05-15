defmodule Gofish.Game do
	use GenServer

	def start_link(name) do
		GenServer.start_link(__MODULE__, name, name: name)
	end

	def get_game_state(server) do
		:not_implemented
	end

	def join_game(server, player) do
		:not_implemented
	end

	def make_play(server, {player, card}) do
		:not_implemented
	end

	def stop(server) do
		GenServer.stop(server)
	end

	## Server Callbacks

	def init() do
		players = %{}
		face_down = []
		face_up = []
		{:ok, {players, nil, face_down, face_up}}
	end

	def handle_call({:make_play, {player, card}}, _from, {players, current_player, face_down, face_up}) do
		
	end
end