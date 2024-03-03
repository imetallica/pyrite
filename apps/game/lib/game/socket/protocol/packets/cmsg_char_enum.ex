defmodule Game.Socket.Protocol.Packets.CmsgCharEnum do
  @moduledoc """
  CMSG_CHAR_ENUM is a World Packet that requests a SMSG_CHAR_ENUM
  from the server. It is sent by the client after receiving a
  successful SMSG_AUTH_RESPONSE.
  """
  alias Game.Socket.Acceptor
  alias Game.Socket.Protocol.Packets.SmsgCharEnum
  alias Shared.Data.CharacterHandler
  alias Shared.Data.Schemas.Character
  alias Shared.Data.Schemas.Pet

  require Logger

  @behaviour Game.Socket.Protocol.ClientPacket

  def handle_packet(_, acceptor = %Acceptor{}) do
    Logger.debug("Handling CMSG_CHAR_ENUM")

    acceptor.session.account
    |> CharacterHandler.all()
    |> Enum.take(10)
    |> then(fn characters ->
      Enum.reduce(
        characters,
        %SmsgCharEnum{amount_of_characters: Enum.count(characters), characters: []},
        fn dbc = %Character{}, acc = %SmsgCharEnum{} ->
          char = %SmsgCharEnum.Character{
            guid: dbc.id,
            name: dbc.name,
            first_login: Character.map(:cinematic, dbc.cinematic)
          }

          %SmsgCharEnum{acc | characters: [char | acc.characters]}
        end
      )
    end)
  end
end
