defmodule Game.Proto.ClientPacket do
  @moduledoc """
  A behaviour that all client packets should implement.
  """
  alias Game.Socket.Acceptor

  @callback handle_packet(packet :: binary(), acceptor :: Acceptor.t()) ::
              {:ok, [nonempty_binary(), ...], Acceptor.t()} | {:error, [nonempty_binary(), ...]}
end
