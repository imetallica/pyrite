defmodule Realmd.Messages.LogonChallenge do
  @moduledoc """
  This module is responsible for handling the first step of authentication
  between the server and the client.

  This step is called "Logon Challenge" and it is separated in these steps:

  1. Client sends a packet.
  2. We check if the identity sent and the length of the identity sent by
  the client match. If it doesn't we raise an `UsernameSizeError`.
  3. We check in the database if the account exists. If it doesn't, we send
  an account not found message back to the client.
  4. If it exists, we check if the account is banned. If it is, we either send
  a temporary or permanent ban message back to the client, depending on the
  kind of ban.
  5. We generate public and private server keys.
  6. We send the public server key together with the salt and a generator.

  The kind of authentication used is a modified version of SRP, version 6.
  More information about [SRP](http://srp.stanford.edu/design.html).
  """
  alias Shared.BinaryData
  alias Data.Schemas.Account
  alias Data.AccountHandler
  alias Shared.Auth.SRP6
  alias Realmd.Socket.Opcodes

  require Logger

  defstruct [
    :id_len,
    :identity,
    :build,
    :account,
    :status,
    :public_server_key,
    :private_server_key
  ]

  @type t() :: %__MODULE__{
          id_len: non_neg_integer(),
          identity: String.t(),
          build: non_neg_integer(),
          account: any(),
          status:
            :identity_size_error | :account_not_found | :account_banned | :account_suspended | :ok,
          public_server_key: binary(),
          private_server_key: binary()
        }

  def fetch_and_check_identity(
        <<_err::size(8), _size::unsigned-little-integer-size(16),
          _game_name::unsigned-little-integer-size(32), _v1::size(8), _v2::size(8), _v3::size(8),
          build::unsigned-little-integer-size(16), _platform::unsigned-little-integer-size(32),
          _os::unsigned-little-integer-size(32), _country::unsigned-little-integer-size(32),
          _tz_bias::unsigned-little-integer-size(32), _ip::unsigned-little-integer-size(32),
          id_len::size(8), identity::binary>>
      ) do
    Logger.debug("Received logon challenge from #{inspect(identity)}.")

    cond do
      id_len === 0 ->
        Logger.error("id_len size is 0. It should be at least 1.")

        {:ok,
         %__MODULE__{
           id_len: id_len,
           identity: identity,
           build: build,
           status: :identity_size_error
         }}

      String.length(identity) !== id_len ->
        Logger.error("id_len size does not match the identity length.")

        {:ok,
         %__MODULE__{
           id_len: id_len,
           identity: identity,
           build: build,
           status: :identity_size_error
         }}

      :otherwise ->
        Logger.debug("Client with build #{build} connected.")
        {:ok, %__MODULE__{id_len: id_len, identity: identity, build: build}}
    end
  end

  def fetch_account(msg = %__MODULE__{identity: identity}) do
    account = AccountHandler.get_by_username(identity)

    cond do
      is_nil(account) ->
        {:ok, %__MODULE__{msg | status: :account_not_found}}

      AccountHandler.banned?(account) ->
        {:ok, %__MODULE__{msg | status: :account_banned}}

      AccountHandler.suspended?(account) ->
        {:ok, %__MODULE__{msg | status: :account_suspended}}

      :otherwise ->
        case AccountHandler.lift_suspension(account) do
          {:error, _} ->
            {:ok, %__MODULE__{msg | status: :account_suspended}}

          {:ok, account = %Account{}} ->
            {public, private} = SRP6.generate_public_and_private_key_for_server(account.verifier)

            {:ok,
             %__MODULE__{
               msg
               | status: :ok,
                 account: account,
                 public_server_key: public,
                 private_server_key: private
             }}
        end
    end
  end

  @compile {:inline, to_binary_message: 1}
  def to_binary_message(%__MODULE__{status: :identity_size_error}),
    do: [
      <<Opcodes.logon_challenge()::size(8)>>,
      <<0::size(8)>>,
      <<Opcodes.logon_failed_unknown_1()::size(8)>>
    ]

  def to_binary_message(%__MODULE__{status: :account_not_found}),
    do: [
      <<Opcodes.logon_challenge()::size(8)>>,
      <<0::size(8)>>,
      <<Opcodes.logon_failed_unknown_account()::size(8)>>
    ]

  def to_binary_message(%__MODULE__{status: :account_suspended}),
    do: [
      <<Opcodes.logon_challenge()::size(8)>>,
      <<0::size(8)>>,
      <<Opcodes.logon_failed_suspended()::size(8)>>
    ]

  def to_binary_message(%__MODULE__{status: :account_banned}),
    do: [
      <<Opcodes.logon_challenge()::size(8)>>,
      <<0::size(8)>>,
      <<Opcodes.logon_failed_banned()::size(8)>>
    ]

  def to_binary_message(%__MODULE__{
        status: :ok,
        public_server_key: public_server_key,
        account: %Account{salt: salt}
      }) do
    [
      <<Opcodes.logon_challenge()::size(8)>>,
      <<0::size(8)>>,
      <<Opcodes.logon_success()::size(8)>>,
      BinaryData.to_little_endian(public_server_key, 256),
      <<byte_size(SRP6.generator())::size(8)>>,
      SRP6.generator(),
      <<byte_size(SRP6.prime())::size(8)>>,
      BinaryData.to_little_endian(SRP6.prime(), 256),
      salt,
      <<0x0123456789ABCDEF::unsigned-little-integer-size(128)>>,
      <<0::size(8)>>
    ]
  end
end
