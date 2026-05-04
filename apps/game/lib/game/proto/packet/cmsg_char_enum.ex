defmodule Game.Proto.Packet.CmsgCharEnum do
  @moduledoc """
  CMSG_CHAR_ENUM is a World Packet that requests a SMSG_CHAR_ENUM
  from the server. It is sent by the client after receiving a
  successful SMSG_AUTH_RESPONSE.
  """
  alias Game.Proto.Packet.SmsgCharEnum
  alias Game.Socket.Acceptor
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
            gender: Character.enum_to_value(:gender, dbc.gender),
            skin: dbc.look.skin,
            face: dbc.look.face,
            hairstyle: dbc.look.hair_style,
            haircolor: dbc.look.hair_colour,
            facialhair: dbc.look.facial_hair,
            level: dbc.level,
            area: Character.enum_to_value(:zone, dbc.zone),
            map: Character.enum_to_value(:map, dbc.map),
            position_x: dbc.position.x,
            position_y: dbc.position.y,
            position_z: dbc.position.z,
            guild_id: 0,
            flags: 0,
            first_login: if(dbc.at_login, do: 1, else: 0),
            pet_display_id: 0,
            pet_level: 0,
            pet_family: 0
          }

          %SmsgCharEnum{acc | characters: [char | acc.characters]}
        end
      )
    end)
    |> SmsgCharEnum.to_binary(account.session_key, acceptor.key_state_encrypt)
    |> then(fn {packet, key_state_encrypt} ->
      {:ok, packet, %Acceptor{acceptor | key_state_encrypt: key_state_encrypt}}
    end)
  end
end
