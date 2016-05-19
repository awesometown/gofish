defmodule Gofish.GameFsm do
	import Gofish.GameState, only: [advance_players: 1, find_player: 2]
	use Fsm, initial_state: :waiting_for_players, initial_data: %Gofish.GameState{}

	defstate waiting_for_players do
		defevent join(player_id), data: gamestate do
			next_state(:waiting_for_players, %{gamestate | players: gamestate.players ++ [%Gofish.PlayerState{player_id: player_id}]})
		end
		defevent start(), data: gamestate = %{players: players} do
			init_game(gamestate, Gofish.Deck.create_shuffled(), 5)
		end
		# Use for setting up test scenarios
		defevent start(cards, num_cards_per_hand), data: gamestate = %{players: players} do
			init_game(gamestate, cards, num_cards_per_hand)		
		end
	end

	defstate turn do
		defevent play(player_id, target, requested_rank), data: gamestate = %{players: [curr_player|_]} do
			if player_id == curr_player.player_id do
				handle_play(player_id, target, requested_rank, gamestate)
				#respond(:ok, :turn, advance_players(gamestate))
			else
				respond(:not_your_turn, :turn)
			end
		end
	end

 	defp init_game(gamestate = %{players: players}, deck, cards_per_hand) do
 		{rest_cards, dealt_players} = Gofish.Dealer.deal(deck, players, cards_per_hand)
		next_state(:turn, %{gamestate | players: dealt_players, face_down_cards: rest_cards})
 	end

	defp handle_play(source_id, target_id, requested_rank, gamestate) do
		source_player = find_player(gamestate, source_id)
		source_card = match_rank(source_player.hand, requested_rank)
		target_player = find_player(gamestate, target_id)
		response = make_play(source_player, target_player, source_card)
		case response do
			{:ok, :go_fish} -> respond(response, :turn, advance_players(gamestate))
			{:ok, matching_card} -> respond(response, :turn, gamestate)
			_ -> respond(response, :turn, gamestate)
		end
	end

	defp match_rank(cards, rank) do
		Enum.find(cards, fn(card) -> card.rank == rank end)
	end

	defp make_play(nil, target_player, _) do {:error, :invalid_source} end
	defp make_play(source_player, nil, _) do {:error, :invalid_target} end
	defp make_play(source_player, source_player, _) do {:error, :invalid_target} end
	defp make_play(source_player, target_player, nil) do {:error, :invalid_card_selected} end
	
	defp make_play(source_player, target_player, source_card) do
		matching_card = Enum.find(target_player.hand, fn(card) -> card.rank == source_card.rank end)
		case matching_card do
			nil -> {:ok, :go_fish}
			_ -> {:ok, matching_card}
		end
	end
end