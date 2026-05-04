defmodule Game.Proto.Packet.CmsgCharCreate do
  @moduledoc """
  CMSG_CHAR_CREATE is a World Packet that is sent after the
  SMSG_CHAR_ENUM is received and the client has created a new
  character. The client will wait for a SMSG_CHAR_CREATE as
  confirmation.
  """
  alias Ecto.Changeset
  alias Game.Proto.AccountResultValues
  alias Game.Proto.Packet.SmsgCharCreate
  alias Game.Socket.Acceptor
  alias Shared.Data.Base.BasePlayer.CreateInfo
  alias Shared.Data.CharacterHandler
  alias Shared.Data.Dbc.ChrClasses
  alias Shared.Data.Dbc.ChrRaces
  alias Shared.Data.Schemas.Character

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

  @max_characters_per_realm 10
  @min_name_length 2
  @max_name_length 12

  @spec handle_packet(binary(), Acceptor.t()) ::
          {:ok, [nonempty_binary(), ...], Acceptor.t()} | {:error, [nonempty_binary(), ...]}
  def handle_packet(packet, acceptor = %Acceptor{}) do
    Logger.debug("Handling [CMSG_CHAR_CREATE]")

    with {:ok, parsed = %__MODULE__{}} <- decode(packet),
         {:ok, parsed = %__MODULE__{}, acceptor = %Acceptor{}} <- validate(parsed, acceptor),
         {:ok, %__MODULE__{}, acceptor = %Acceptor{}} <- handle(parsed, acceptor) do
      encode(acceptor)
    end
  end

  defp decode(packet) do
    {character_name, rest} = parse_character_name(packet, <<>>)
    decode_body(character_name, rest)
  end

  defp decode_body(
         character_name,
         <<race::unsigned-integer-size(8), class::unsigned-integer-size(8),
           gender::unsigned-integer-size(8), skin::unsigned-integer-size(8),
           face::unsigned-integer-size(8), hairstyle::unsigned-integer-size(8),
           haircolor::unsigned-integer-size(8), facialhair::unsigned-integer-size(8),
           outfit_id::unsigned-integer-size(8)>>
       ) do
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

  defp decode_body(_character_name, _rest) do
    Logger.warning("Malformed CMSG_CHAR_CREATE packet")
    :ignore
  end

  defp parse_character_name(<<0, rest::binary>>, character_name), do: {character_name, rest}

  defp parse_character_name(
         <<letter::unsigned-integer-size(8), rest::binary>>,
         character_name
       ) do
    parse_character_name(rest, <<character_name::binary, letter>>)
  end

  defp parse_character_name(<<>>, character_name), do: {character_name, <<>>}

  defp validate(parsed = %__MODULE__{}, acceptor = %Acceptor{}) do
    race = Enum.find(ChrRaces.all(), &(&1.id == parsed.race))
    class = Enum.find(ChrClasses.all(), &(&1.id == parsed.class))
    normalised_name = normalize_name(parsed.character_name)

    with :ok <- validate_race_class(race, class),
         :ok <- validate_name(parsed.character_name, normalised_name),
         :ok <- validate_appearance(parsed),
         :ok <- validate_character_count(acceptor.account) do
      {:ok, %{parsed | character_name: normalised_name}, acceptor}
    else
      {:error, result_code} -> send_error(result_code, acceptor)
    end
  end

  defp validate_race_class(race, class) do
    if is_nil(race) or is_nil(class),
      do: {:error, AccountResultValues.char_create_error()},
      else: :ok
  end

  defp validate_name(raw_name, normalised_name) do
    cond do
      not String.printable?(raw_name) ->
        {:error, AccountResultValues.char_create_error()}

      String.length(normalised_name) < @min_name_length ->
        {:error, AccountResultValues.char_name_too_short()}

      String.length(normalised_name) > @max_name_length ->
        {:error, AccountResultValues.char_name_too_long()}

      true ->
        :ok
    end
  end

  defp validate_appearance(parsed) do
    cond do
      parsed.gender not in 0..1 ->
        {:error, AccountResultValues.char_create_error()}

      not valid_appearance?(parsed) ->
        {:error, AccountResultValues.char_create_error()}

      true ->
        :ok
    end
  end

  defp validate_character_count(account) do
    if Enum.count(CharacterHandler.all(account)) >= @max_characters_per_realm,
      do: {:error, AccountResultValues.char_create_account_limit()},
      else: :ok
  end

  defp handle(parsed = %__MODULE__{}, acceptor = %Acceptor{}) do
    Logger.debug("Creating character: #{parsed.character_name}.")

    race = Enum.find(ChrRaces.all(), &(&1.id == parsed.race))
    class = Enum.find(ChrClasses.all(), &(&1.id == parsed.class))
    race_atom = Character.value_to_enum(:race, parsed.race)
    class_atom = Character.value_to_enum(:class, parsed.class)
    gender_atom = Character.value_to_enum(:gender, parsed.gender)

    case CreateInfo.new(race, class) do
      nil ->
        Logger.warning("Unsupported race/class combo: #{race_atom}/#{class_atom}")
        send_error(AccountResultValues.char_create_error(), acceptor)

      create_info ->
        create_character(parsed, acceptor, race_atom, class_atom, gender_atom, create_info)
    end
  end

  defp create_character(parsed, acceptor, race_atom, class_atom, gender_atom, create_info) do
    race_entry = Enum.find(ChrRaces.all(), &(&1.id == parsed.race))

    params = %{
      account_id: acceptor.account.id,
      name: parsed.character_name,
      race: race_atom,
      class: class_atom,
      gender: gender_atom,
      level: 1,
      xp: 0,
      money: 0,
      map: create_info.map,
      zone: create_info.zone,
      taximask: Integer.to_string(race_entry.starting_taxi),
      online: false,
      cinematic: false,
      total_time: 0,
      level_time: 0,
      logout_time: 0,
      logout_resting: false,
      rest_bonus: 0.0,
      reset_talents_cost: 0,
      extra_flags: 0,
      stable_slots: 0,
      at_login: true,
      watched_faction: -1,
      explored_zones: [],
      equipment_cache: [],
      ammo_id: 0,
      position: %{
        x: create_info.position.x,
        y: create_info.position.y,
        z: create_info.position.z,
        orientation: create_info.position.orientation
      },
      look: %{
        skin: parsed.skin,
        face: parsed.face,
        hair_style: parsed.hairstyle,
        hair_colour: parsed.haircolor,
        facial_hair: parsed.facialhair,
        rest_state: :normal
      },
      transport: %{x: 0.0, y: 0.0, z: 0.0, orientation: 0.0, identification: 0},
      honour: %{
        highest_rank: :none,
        standing: :none,
        rating: 0.0,
        honourable_kills: 0,
        dishonourable_kills: 0
      },
      current_stats: %{
        drunk: 0,
        health: create_info.class_stats.base_health,
        mana: create_info.class_stats.base_mana,
        rage: 0,
        pet_focus: 0,
        energy: 0,
        pet_happiness: 0
      }
    }

    params
    |> CharacterHandler.create()
    |> handle_create_result(parsed, acceptor)
  end

  defp handle_create_result({:ok, _character}, parsed, acceptor) do
    Logger.debug("Character created: #{parsed.character_name}.")
    {:ok, parsed, acceptor}
  end

  defp handle_create_result({:error, %Changeset{} = changeset}, _parsed, acceptor) do
    Logger.error("Failed to create character: #{inspect(changeset.errors)}")

    case changeset.errors do
      [name: {"has already been taken", _}] ->
        send_error(AccountResultValues.char_create_name_in_use(), acceptor)

      _ ->
        send_error(AccountResultValues.char_create_error(), acceptor)
    end
  end

  defp encode(acceptor = %Acceptor{}) do
    Logger.debug("Sending [SMSG_CHAR_CREATE]: success.")

    [result: AccountResultValues.char_create_success()]
    |> SmsgCharCreate.new()
    |> SmsgCharCreate.to_binary(acceptor.account.session_key, acceptor.key_state_encrypt)
    |> then(fn {data, key_state_encrypt} ->
      {:ok, data, %Acceptor{acceptor | key_state_encrypt: key_state_encrypt}}
    end)
  end

  defp send_error(result_code, acceptor = %Acceptor{}) do
    [result: result_code]
    |> SmsgCharCreate.new()
    |> SmsgCharCreate.to_binary(acceptor.account.session_key, acceptor.key_state_encrypt)
    |> then(fn {packet, key_state_encrypt} ->
      {:ok, packet, %Acceptor{acceptor | key_state_encrypt: key_state_encrypt}}
    end)
  end

  defp normalize_name(<<first::binary-size(1), rest::binary>>) do
    String.upcase(first) <> String.downcase(rest)
  end

  defp normalize_name(name), do: name

  defp valid_appearance?(parsed) do
    [parsed.skin, parsed.face, parsed.hairstyle, parsed.haircolor, parsed.facialhair]
    |> Enum.all?(&(&1 in 0..255))
  end
end
