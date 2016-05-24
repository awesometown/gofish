defmodule Gofish.Game do
	use GenServer

	def start_link(name) do
		GenServer.start_link(__MODULE__, name, name: name)
	end

	def get_game_state(_server) do
		:not_implemented
	end

	def join_game(_server, _player) do
		:not_implemented
	end

	def make_play(_server, {_player, _card}) do
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

	def handle_call({:make_play, {_player, _card}}, _from, {_players, _current_player, _face_down, _face_up}) do
		
	end
end