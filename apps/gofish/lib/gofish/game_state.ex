defmodule Gofish.GameState do
	defstruct players: [], face_down_cards: [], face_up_cards: []

	def advance_players(%{players: [current | rest]} = gamestate) do
		%{gamestate | players: rest ++ [current]}
	end

	def current_player_id(%{players: [current | _]}) do
		current.player_id
	end
end