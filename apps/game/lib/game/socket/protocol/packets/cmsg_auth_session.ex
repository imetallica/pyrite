defmodule Game.Socket.Protocol.Packets.CmsgAuthSession do
  @moduledoc """
  Handles the cmsg_auth_session packet.
  """
  alias Data.AccountHandler
  alias Data.Schemas.Account
  alias Shared.SupportedBuilds
  alias Game.Socket.Acceptor
  alias Game.Socket.Protocol.AccountResultValues
  alias Game.Socket.Protocol.Packets.SmsgAuthResponse
  alias Game.World

  require Logger

  defstruct [
    :username,
    :client_seed,
    :client_proof,
    :build
  ]

  @behaviour Game.Socket.Protocol.ClientPacket

  def handle_packet(packet, state = %Acceptor{}) do
    with {:ok, parsed = %__MODULE__{}, state} <- parse(packet, state),
         {:ok, validated = %__MODULE__{}, state} <- validate(parsed, state) do
      handle(validated, state)
    end
  end

  defp parse(
         <<build::unsigned-little-integer-size(32), _::unsigned-little-integer-size(32),
           rest::binary>>,
         state = %Acceptor{}
       ) do
    {username, rest} = parse_username(rest, <<>>)

    <<client_seed::unsigned-little-integer-size(32), client_proof::binary-size(20),
      _::unsigned-little-integer-size(32), _::binary>> = rest

    Logger.debug(
      "Received cmsg_auth_session packet with username #{username} client seed #{client_seed} and proof #{inspect(client_proof)}."
    )

    session = World.get_session(username)

    if is_nil(session) do
      {:ok,
       %__MODULE__{
         username: username,
         client_seed: client_seed,
         client_proof: client_proof,
         build: build
       }, state}
    else
      Logger.error("Session already exists for the player: #{username}.")

      {:error, SmsgAuthResponse.new(result: AccountResultValues.auth_already_online()),
       %Acceptor{state | encryption_salt: client_seed, encryption_proof: client_proof}}
    end
  end

  # Username is <<0>> terminated and we don't know the size prior, so this is the
  # only way we can parse it.
  defp parse_username(<<0, rest::binary>>, acc), do: {acc, rest}

  defp parse_username(<<character, rest::binary>>, acc) do
    parse_username(rest, <<acc::binary, character>>)
  end

  defp validate(%__MODULE__{} = packet, state = %Acceptor{}) do
    Logger.debug("Validating cmsg_auth_session packet.")

    cond do
      not String.printable?(packet.username) ->
        Logger.error("Malformed packet: #{inspect(packet.username)}.")

        {:error, SmsgAuthResponse.new(result: AccountResultValues.auth_reject()), state}

      packet.build not in SupportedBuilds.versions() ->
        Logger.warning("Client build not supported: #{packet.build}.")

        {:error, SmsgAuthResponse.new(result: AccountResultValues.auth_version_mismatch()), state}

      :otherwise ->
        {:ok, packet, state}
    end
  end

  defp handle(%__MODULE__{} = packet, state = %Acceptor{}) do
    account = AccountHandler.get_by_username(packet.username)

    cond do
      is_nil(account) ->
        Logger.warning("Account not found: #{packet.username}.")

        {:error, SmsgAuthResponse.new(result: AccountResultValues.auth_unknown_account()), state}

      AccountHandler.banned?(account) ->
        Logger.warning("Account is banned: #{packet.username}.")

        {:error, SmsgAuthResponse.new(result: AccountResultValues.auth_banned()), state}

      AccountHandler.suspended?(account) ->
        Logger.warning("Account is suspended: #{packet.username}.")

        {:error, SmsgAuthResponse.new(result: AccountResultValues.auth_suspended()), state}

      :otherwise ->
        Logger.debug("Account found: #{packet.username}.")

        do_handle(account, packet, state)
    end
  end

  defp do_handle(account = %Account{}, packet = %__MODULE__{}, state = %Acceptor{}) do
    # TODO: implement
    {:ok, SmsgAuthResponse.new(result: AccountResultValues.auth_ok()), state}
  end
end
