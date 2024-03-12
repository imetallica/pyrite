defmodule Game.Proto.Packet.CmsgAuthSession do
  @moduledoc """
  Handles the cmsg_auth_session packet.
  """
  alias Game.Socket.Acceptor
  alias Shared.Data.AccountHandler
  alias Shared.SupportedBuilds
  alias Game.Proto.AccountResultValues
  alias Game.Proto.Packet.SmsgAuthResponse
  alias Game.World

  require Logger

  defstruct [
    :username,
    :client_seed,
    :client_proof,
    :build
  ]

  @behaviour Game.Proto.ClientPacket

  def handle_packet(packet, state = %Acceptor{}) when is_binary(packet) do
    with {:ok, parsed = %__MODULE__{}} <- parse(packet),
         {:ok, validated = %__MODULE__{}} <- validate(parsed) do
      handle(validated, state)
    end
  end

  defp parse(
         <<build::unsigned-little-integer-size(32), _::unsigned-little-integer-size(32),
           rest::binary>>
       ) do
    {username, rest} = parse_username(rest, <<>>)

    <<client_seed::unsigned-little-integer-size(32), client_proof::little-binary-size(20),
      _::unsigned-little-integer-size(32), _::little-binary>> = rest

    Logger.debug(
      "Received cmsg_auth_session packet with username #{username} client seed #{client_seed} and proof #{inspect(client_proof)}."
    )

    {:ok,
     %__MODULE__{
       username: username,
       client_seed: client_seed,
       client_proof: client_proof,
       build: build
     }}
  end

  # Username is <<0>> terminated and we don't know the size prior, so this is the
  # only way we can parse it.
  defp parse_username(<<0, rest::binary>>, acc), do: {acc, rest}

  defp parse_username(<<character, rest::binary>>, acc) do
    parse_username(rest, <<acc::binary, character>>)
  end

  defp validate(%__MODULE__{} = packet) do
    Logger.debug("Validating cmsg_auth_session packet.")

    cond do
      not String.printable?(packet.username) ->
        Logger.error("Malformed packet: #{inspect(packet.username)}.")

        [result: AccountResultValues.auth_reject()]
        |> SmsgAuthResponse.new()
        |> SmsgAuthResponse.to_binary()
        |> then(fn result -> {:error, result} end)

      packet.build not in SupportedBuilds.versions() ->
        Logger.warning("Client build not supported: #{packet.build}.")

        [result: AccountResultValues.auth_version_mismatch()]
        |> SmsgAuthResponse.new()
        |> SmsgAuthResponse.to_binary()
        |> then(fn result -> {:error, result} end)

      :otherwise ->
        {:ok, packet}
    end
  end

  # @n <<0x894B645E89E1535BBDAD5B8B290650530801B18EBFBF5E8FAB3C82872A3E9BB7::unsigned-big-integer-size(
  #        256
  #      )>>

  # @g <<7::size(8)>>

  defp handle(%__MODULE__{} = packet, acceptor = %Acceptor{}) do
    session = World.get_session(packet.username)
    account = AccountHandler.get_by_username(packet.username)

    # v = account.verifier
    # s = account.salt
    # key = account.session_key

    # TODO: Handle sha check of the client.

    cond do
      is_nil(account) ->
        Logger.warning("Account not found: #{packet.username}.")

        [result: AccountResultValues.auth_unknown_account()]
        |> SmsgAuthResponse.new()
        |> SmsgAuthResponse.to_binary()
        |> then(fn result -> {:error, result} end)

      not is_nil(session) ->
        Logger.error("Session already exists for the player: #{session.username}.")

        [result: AccountResultValues.auth_already_online()]
        |> SmsgAuthResponse.new()
        |> SmsgAuthResponse.to_binary(account.session_key, acceptor.key_state_encrypt)
        |> then(fn {result, _} -> {:error, result} end)

      AccountHandler.banned?(account) ->
        Logger.warning("Account is banned: #{packet.username}.")

        [result: AccountResultValues.auth_banned()]
        |> SmsgAuthResponse.new()
        |> SmsgAuthResponse.to_binary(account.session_key, acceptor.key_state_encrypt)
        |> then(fn {result, _} -> {:error, result} end)

      AccountHandler.suspended?(account) ->
        Logger.warning("Account is suspended: #{packet.username}.")

        [result: AccountResultValues.auth_suspended()]
        |> SmsgAuthResponse.new()
        |> SmsgAuthResponse.to_binary(account.session_key, acceptor.key_state_encrypt)
        |> then(fn {result, _} -> {:error, result} end)

      :otherwise ->
        Logger.debug("Account found: #{packet.username}.")

        [
          result: AccountResultValues.auth_ok(),
          billing_time: 0,
          billing_flags: 0,
          billing_rested: 0
        ]
        |> SmsgAuthResponse.new()
        |> SmsgAuthResponse.to_binary(account.session_key, acceptor.key_state_encrypt)
        |> then(fn {result, key_state_encrypt} ->
          {:ok, result,
           %Acceptor{
             acceptor
             | account: account,
               encrypted?: true,
               key_state_encrypt: key_state_encrypt
           }}
        end)
    end
  end
end
