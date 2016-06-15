defmodule Gofish.GameServerData do
	defstruct fsm: Gofish.Game.GameFsm.new, player_map: %Gofish.PlayerMap{}
end