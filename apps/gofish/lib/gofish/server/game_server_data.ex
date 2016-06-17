defmodule Gofish.Server.GameServerData do
	defstruct fsm: Gofish.Game.GameFsm.new, player_map: %Gofish.Server.PlayerMap{}
end