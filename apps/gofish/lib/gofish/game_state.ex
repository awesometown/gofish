defmodule Gofish.GameState do
	defstruct players: [], deck: [], face_up_cards: []

	def new(players, deck) do
		%Gofish.GameState{players: players, deck: deck}
	end

	def advance_players([current|rest]) do
		players = rest ++ [current]
		if length(hd(players).hand) > 0 do
			players
		else
			advance_players(players)
		end
	end

	def advance_players(gamestate) do
		%{gamestate | players: advance_players(gamestate.players)}
	end

	def current_player_id(%{players: [current | _]}) do
		current.player_id
	end

	def find_player(%{players: players}, target_id) do
		player = Enum.find(players, fn(p) -> p.player_id == target_id end)
		case player do
			nil -> {:error, :no_player}
			_ -> player
		end
	end

	def update_player(%{players: players} = gamestate, player) do
		case find_player_index(players, player) do
			nil -> {:error, :invalid_player_specified}
			p_index -> players = List.replace_at(players, p_index, player)
					   %{gamestate | players: players}
		end		
	end

	def is_game_over?(%{deck: [_]}) do
		false
	end

	def is_game_over?(%{players: players, deck: []}) do
		Enum.all?(players, fn(player) -> length(player.hand) == 0 end)
	end

	defp find_player_index(players, player) do
		Enum.find_index(players, fn(%{player_id: pid}) -> pid == player.player_id end)
	end
end