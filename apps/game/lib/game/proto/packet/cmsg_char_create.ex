defmodule Game.Proto.Packet.CmsgCharCreate do
  @moduledoc """
  CMSG_CHAR_CREATE is a World Packet that is sent after the
  SMSG_CHAR_ENUM is received and the client has created a new
  character. The client will wait for a SMSG_CHAR_CREATE as
  confirmation.
  """
  alias Game.Proto.AccountResultValues
  alias Game.Proto.Packet.SmsgCharCreate
  alias Game.Socket.Acceptor
  alias Shared.Data.CharacterHandler
  alias Shared.Data.Dbc.ChrRaces
  alias Shared.Data.Dbc.ChrClasses

  require Logger

  defstruct [
    :character_name,
    :race,
    :class,
    :gender,
    :skin,
    :face,
    :hairstyle,
    :haircolor,
    :facialhair,
    :outfit_id
  ]

  @behaviour Game.Proto.ClientPacket

  def handle_packet(packet, acceptor = %Acceptor{}) do
    Logger.debug("Handling [CMSG_CHAR_CREATE]")

    with {:ok, parsed = %__MODULE__{}} <- decode(packet),
         {:ok, parsed = %__MODULE__{}, acceptor = %Acceptor{}} <- validate(parsed, acceptor),
         {:ok, parsed = %__MODULE__{}, acceptor = %Acceptor{}} <- handle(parsed, acceptor) do
      encode(parsed, acceptor)
    end
  end

  defp decode(packet) do
    {character_name, rest} = parse_character_name(packet, <<>>)

    <<race::unsigned-big-integer-size(8), class::unsigned-big-integer-size(8),
      gender::unsigned-big-integer-size(8), skin::unsigned-big-integer-size(8),
      face::unsigned-big-integer-size(8), hairstyle::unsigned-big-integer-size(8),
      haircolor::unsigned-big-integer-size(8), facialhair::unsigned-big-integer-size(8),
      outfit_id::unsigned-big-integer-size(8)>> = rest

    {:ok,
     %__MODULE__{
       character_name: character_name,
       race: race,
       class: class,
       gender: gender,
       skin: skin,
       face: face,
       hairstyle: hairstyle,
       haircolor: haircolor,
       facialhair: facialhair,
       outfit_id: outfit_id
     }}
  end

  defp parse_character_name(<<0, rest::binary>>, character_name), do: {character_name, rest}

  defp parse_character_name(
         <<letter::unsigned-big-integer-size(8), rest::binary>>,
         character_name
       ),
       do: parse_character_name(rest, <<character_name::binary, letter::binary>>)

  defp validate(parsed = %__MODULE__{}, acceptor = %Acceptor{}) do
    race = Enum.find(ChrRaces.all(), &(&1.id == parsed.race))
    class = Enum.find(ChrClasses.all(), &(&1.id == parsed.class))
    current_characters = CharacterHandler.all(acceptor.account)

    cond do
      is_nil(race) or is_nil(class) ->
        [result: AccountResultValues.char_create_error()]
        |> SmsgCharCreate.new()
        |> SmsgCharCreate.to_binary(acceptor.account.session_key, acceptor.key_state_encrypt)
        |> then(fn {packet, key_state_encrypt} ->
          {:ok, packet, %Acceptor{acceptor | key_state_encrypt: key_state_encrypt}}
        end)

      not String.printable?(parsed.character_name) ->
        [result: AccountResultValues.char_create_name_invalid()]
        |> SmsgCharCreate.new()
        |> SmsgCharCreate.to_binary(acceptor.account.session_key, acceptor.key_state_encrypt)
        |> then(fn {packet, key_state_encrypt} ->
          {:ok, packet, %Acceptor{acceptor | key_state_encrypt: key_state_encrypt}}
        end)

      Enum.count(current_characters) >= 10 ->
        [result: AccountResultValues.char_create_account_limit()]
        |> SmsgCharCreate.new()
        |> SmsgCharCreate.to_binary(acceptor.account.session_key, acceptor.key_state_encrypt)
        |> then(fn {packet, key_state_encrypt} ->
          {:ok, packet, %Acceptor{acceptor | key_state_encrypt: key_state_encrypt}}
        end)

      # TODO: Cross faction disable, server limit, faction disabled, etc...
      :otherwise ->
        {:ok, parsed, acceptor}
    end
  end

  defp handle(parsed = %__MODULE__{}, acceptor = %Acceptor{}) do
    Logger.debug("Creating character: #{parsed.character_name}.")

    %{
      account_id: acceptor.account.id,
      name: parsed.character_name,
      race: parsed.race,
      class: parsed.class,
      gender: parsed.gender,
      level: 1,
      look: %{
        skin: parsed.skin,
        face: parsed.face,
        hair_style: parsed.hairstyle,
        hair_colour: parsed.haircolor,
        facial_hair: parsed.facialhair,
        rest_state: :normal
      },
      current_stats: %{}
    }

    {:ok, parsed, acceptor}
  end

  defp encode(parsed = %__MODULE__{}, acceptor = %Acceptor{}) do
    Logger.debug("Sending [SMSG_CHAR_CREATE]: #{parsed.character_name}.")

    [character_name: parsed.character_name]
    |> SmsgCharCreate.new()
    |> SmsgCharCreate.to_binary(acceptor.account.session_key, acceptor.key_state_encrypt)
    |> then(fn {data, key_state_encrypt} ->
      {:ok, data, %Acceptor{acceptor | key_state_encrypt: key_state_encrypt}}
    end)
  end
end
