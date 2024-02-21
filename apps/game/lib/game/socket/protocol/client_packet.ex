defmodule Game.Socket.Protocol.ClientPacket do
  alias Game.Socket.Acceptor

  @doc """
  A behaviour that all client packets should implement.
  """

  @callback handle_packet(packet :: binary(), acceptor :: Acceptor.t()) ::
              {:ok, struct(), Acceptor.t()} | {:error, term(), Acceptor.t()}
end
