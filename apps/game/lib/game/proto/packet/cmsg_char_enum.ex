defmodule Game.Proto.Packet.CmsgCharEnum do
  @moduledoc """
  CMSG_CHAR_ENUM is a World Packet that requests a SMSG_CHAR_ENUM
  from the server. It is sent by the client after receiving a
  successful SMSG_AUTH_RESPONSE.
  """
  alias Game.Socket.Acceptor
  alias Game.Proto.Packet.SmsgCharEnum
  alias Shared.Data.CharacterHandler
  alias Shared.Data.Schemas.Account
  alias Shared.Data.Schemas.Character
  # alias Shared.Data.Schemas.Pet

  require Logger

  @behaviour Game.Proto.ClientPacket

  def handle_packet(_, acceptor = %Acceptor{account: account = %Account{}}) do
    Logger.debug("Handling CMSG_CHAR_ENUM")

    account
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
            race: Character.enum_to_value(:race, dbc.race),
            class: Character.enum_to_value(:class, dbc.class),
            gender: Character.enum_to_value(:gender, dbc.gender)
          }

          %SmsgCharEnum{acc | characters: [char | acc.characters]}
        end
      )
    end)
    |> then(fn packet ->
      {:ok, SmsgCharEnum.to_binary(packet, account.session_key), acceptor}
    end)
  end
end
