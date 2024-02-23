defmodule Game.Socket.Protocol.Packets.CmsgAuthSession do
  @moduledoc """
  Handles the cmsg_auth_session packet.
  """
  alias Shared.Data.AccountHandler
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

  def handle_packet(packet, state = %Acceptor{}) when is_binary(packet) do
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

    <<client_seed::unsigned-little-integer-size(32), client_proof::little-binary-size(20),
      _::unsigned-little-integer-size(32), _::little-binary>> = rest

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
       },
       %Acceptor{
         state
         | client_seed: client_seed,
           client_proof: client_proof
       }}
    else
      Logger.error("Session already exists for the player: #{username}.")

      {:error, SmsgAuthResponse.new(result: AccountResultValues.auth_already_online()),
       %Acceptor{state | client_seed: client_seed, client_proof: client_proof}}
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

        {:error, SmsgAuthResponse.new(result: AccountResultValues.auth_reject()),
         %Acceptor{
           state
           | client_seed: packet.client_seed,
             client_proof: packet.client_proof
         }}

      packet.build not in SupportedBuilds.versions() ->
        Logger.warning("Client build not supported: #{packet.build}.")

        {:error, SmsgAuthResponse.new(result: AccountResultValues.auth_version_mismatch()),
         %Acceptor{
           state
           | client_seed: packet.client_seed,
             client_proof: packet.client_proof
         }}

      :otherwise ->
        {:ok, packet,
         %Acceptor{
           state
           | client_seed: packet.client_seed,
             client_proof: packet.client_proof
         }}
    end
  end

  # @n <<0x894B645E89E1535BBDAD5B8B290650530801B18EBFBF5E8FAB3C82872A3E9BB7::unsigned-big-integer-size(
  #        256
  #      )>>

  # @g <<7::size(8)>>

  defp handle(%__MODULE__{} = packet, state = %Acceptor{}) do
    account = AccountHandler.get_by_username(packet.username)

    if is_nil(account) do
      Logger.warning("Account not found: #{packet.username}.")

      {:error, SmsgAuthResponse.new(result: AccountResultValues.auth_unknown_account()), state}
    else
      # v = account.verifier
      # s = account.salt
      key = account.session_key

      # TODO: Handle sha check of the client.

      cond do
        AccountHandler.banned?(account) ->
          Logger.warning("Account is banned: #{packet.username}.")

          {:error, SmsgAuthResponse.new(result: AccountResultValues.auth_banned()),
           %Acceptor{state | session_key: key}}

        AccountHandler.suspended?(account) ->
          Logger.warning("Account is suspended: #{packet.username}.")

          {:error, SmsgAuthResponse.new(result: AccountResultValues.auth_suspended()),
           %Acceptor{state | session_key: key}}

        :otherwise ->
          Logger.debug("Account found: #{packet.username}.")

          {:ok,
           SmsgAuthResponse.new(
             result: AccountResultValues.auth_ok(),
             billing_time: 0,
             billing_flags: 0,
             billing_rested: 0
           ), %Acceptor{state | session_key: key}}
      end
    end
  end
end
