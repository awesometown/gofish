defmodule Gofish.GameFsm do
	import Gofish.GameState, only: [advance_players: 1]
	use Fsm, initial_state: :waiting_for_players, initial_data: %Gofish.GameState{}

	defstate waiting_for_players do
		defevent join(player_id), data: gamestate do
			next_state(:waiting_for_players, %{gamestate | players: gamestate.players ++ [%Gofish.PlayerState{player_id: player_id}]})
		end
		defevent start(), data: gamestate = %{players: players} do
			{rest_cards, dealt_players} = Gofish.Dealer.deal(Gofish.Deck.create_shuffled(), players, 5)
			next_state(:turn, %{gamestate | players: dealt_players, face_down_cards: rest_cards})
		end
	end

	defstate turn do
		defevent play(player_id, card), data: gamestate = %{players: [curr_player|_]} do
			if player_id == curr_player.player_id do
				respond(:ok, :turn, advance_players(gamestate))
			else
				respond(:not_your_turn, :turn)
			end
		end
	end

	#def next_player(current_player, players) do
	#	case current_player do
	#		last(players) -> hd(players)
	#		_ ->
	#end 
end