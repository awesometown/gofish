defmodule Gofish.GameFsm do
	import Gofish.GameState
	import Logger
	
	alias Gofish.PlayerState

	use Fsm, initial_state: :waiting_for_players, initial_data: %Gofish.GameState{}

	defstate waiting_for_players do
		defevent join(player_id), data: gamestate do
			next_state(:waiting_for_players, %{gamestate | players: gamestate.players ++ [%Gofish.PlayerState{player_id: player_id}]})
		end
		defevent start(), data: gamestate do
			init_game(gamestate, Gofish.Deck.create_shuffled(), 5)
		end
		# Use for setting up test scenarios
		defevent start(cards, num_cards_per_hand), data: gamestate do
			init_game(gamestate, cards, num_cards_per_hand)		
		end
	end

	defstate turn do
		defevent play(player_id, target, requested_rank), data: gamestate = %{players: [curr_player|_]} do
			if player_id == curr_player.player_id do
				handle_play(player_id, target, requested_rank, gamestate)
			else
				respond(:not_your_turn, :turn)
			end
		end
	end

	defstate game_over do
		
	end

 	defp init_game(gamestate = %{players: players}, deck, cards_per_hand) do
 		{rest_cards, dealt_players} = Gofish.Dealer.deal(deck, players, cards_per_hand)
		next_state(:turn, %{gamestate | players: dealt_players, deck: rest_cards})
 	end

	defp handle_play(source_id, target_id, requested_rank, gamestate) do
		debug("Play: #{source_id} -> #{target_id}, requesting #{requested_rank}")
		debug(inspect(gamestate))
		response = case validate_play(gamestate, source_id, target_id, requested_rank) do
			{:ok, source_player, target_player, source_card} -> process_play(gamestate, source_player, target_player, source_card)
			{:error, code} -> respond({:error, code}, :turn, gamestate)
		end
		debug_response(response)
	end

	defp process_play(gamestate, source, target, source_card) do
		matching_card = Enum.find(target.hand, fn(card) -> card.rank == source_card.rank end)
		case matching_card do
			nil -> go_fish(gamestate)
			_ -> card_exchange(gamestate, source, target, source_card, matching_card)
		end
	end

	defp validate_play(gamestate, source_id, target_id, requested_rank) do
		source_player = find_player(gamestate, source_id)
		source_card = match_rank(source_player.hand, requested_rank)
		target_player = find_player(gamestate, target_id)
		validate_play(source_player, target_player, source_card)
	end

	defp validate_play(nil, _target_player, _source_card) do {:error, :invalid_source} end
	defp validate_play(_source_player, nil, _source_card) do {:error, :invalid_target} end
	defp validate_play(source_player, source_player, _) do {:error, :invalid_target} end
	defp validate_play(_source_player, _target_player, nil) do {:error, :invalid_card_selected} end
	defp validate_play(source_player, target_player, source_card) do {:ok, source_player, target_player, source_card} end

	defp match_rank(cards, rank) do
		Enum.find(cards, fn(card) -> card.rank == rank end)
	end

	defp go_fish(gamestate  = %{deck: [top_card|remaining_cards], players: [curr_player|rest_players]}) do
		curr_player = PlayerState.deal_card(curr_player, top_card)
		gamestate = gamestate
					|> update_player(curr_player)
					|> advance_players
		respond(:go_fish, :turn, gamestate)
	end

	defp go_fish(gamestate  = %{deck: [], players: players}) do
		respond(:go_fish, :turn, advance_players(gamestate))
	end

	defp card_exchange(gamestate, source, target, source_card, matching_card) do
		{:ok, source, target} = Gofish.Dealer.exchange_cards(source, target, source_card, matching_card)		
		gamestate = gamestate |> update_player(source) |> update_player(target)
		if is_game_over?(gamestate) do
			respond({:match, source_card, matching_card}, :game_over, gamestate)
		else
			respond({:match, source_card, matching_card}, :turn, gamestate)
		end
	end

	defp debug_response(response = {:action_responses, action_responses}) do
		respond = Keyword.fetch!(action_responses, :respond)
		debug("Play resulted in #{inspect(respond)} moving to state #{Keyword.fetch!(action_responses, :next_state)}")
		response
	end
end