defmodule Realmd.Messages.LogonProof do
  @moduledoc """
  This module is responsible for handling the second step of the authentication
  between client and server.

  These functions only are called if, the first step of authentication was successful.

  -----------------------------------------------------------------------------------
  TODO: In this step, add support for checking WoW client version and patch handling.
  -----------------------------------------------------------------------------------
  """
  alias Shared.Data.AccountHandler
  alias Shared.SupportedBuilds
  alias Realmd.Socket.Acceptor
  alias Realmd.Socket.Opcodes
  alias Shared.Auth.SRP6
  alias Shared.BinaryData

  require Logger

  defstruct [
    :m2,
    :session_key,
    :public_client_key,
    :client_m1,
    :build,
    :status
  ]

  @type t() :: %__MODULE__{
          m2: binary(),
          session_key: binary(),
          public_client_key: binary(),
          client_m1: binary(),
          build: non_neg_integer(),
          status: :ok | :invalid_password
        }

  def fetch_logon_proof(
        <<l_public_client::unsigned-little-integer-size(256),
          l_m1::unsigned-little-integer-size(160), _crc_hash::unsigned-little-integer-size(160),
          _num_keys::size(8), _unk::size(8)>>
      ) do
    Logger.debug("Received logon proof from client.")

    {:ok,
     %__MODULE__{
       public_client_key: <<l_public_client::unsigned-big-integer-size(256)>>,
       client_m1: <<l_m1::unsigned-big-integer-size(160)>>
     }}
  end

  def fetch_server_key(lp = %__MODULE__{}, acceptor = %Acceptor{}) do
    if acceptor.build in SupportedBuilds.versions() do
      server_session_key =
        SRP6.compute_server_session_key(
          acceptor.private_server_key,
          acceptor.public_server_key,
          lp.public_client_key,
          acceptor.verifier
        )

      key = SRP6.interleave_hash(server_session_key)

      {:ok,
       %__MODULE__{
         lp
         | session_key: key,
           build: acceptor.build
       }}
    else
      {:ok, %__MODULE__{lp | status: :invalid_build}}
    end
  end

  def check_password(lp = %__MODULE__{}, acceptor = %Acceptor{}) do
    server_m1 =
      SRP6.m1(
        String.upcase(acceptor.account.username),
        acceptor.account.salt,
        lp.public_client_key,
        acceptor.public_server_key,
        lp.session_key
      )

    if server_m1 === lp.client_m1 do
      Logger.debug("Client password is correct.")

      lp.public_client_key
      |> SRP6.m2(server_m1, lp.session_key)
      |> then(fn m2 ->
        # TODO: The session key should be shared to the game server and,
        # maybe we create a new session there. We need erlang distribution
        # for that.
        AccountHandler.set_session_key(
          String.upcase(acceptor.account.username),
          lp.session_key
        )

        {:ok, %__MODULE__{lp | m2: m2, status: :ok}}
      end)
    else
      Logger.debug("Client password is incorrect.")

      {:ok, %__MODULE__{lp | status: :invalid_password}}
    end
  end

  @compile {:inline, to_binary_message: 1}
  def to_binary_message(%__MODULE__{status: :ok, m2: m2}),
    do: [
      <<Opcodes.logon_proof()::size(8)>>,
      <<Opcodes.logon_success()::size(8)>>,
      BinaryData.to_little_endian(m2, 160),
      <<0::size(8)>>,
      <<0::size(8)>>,
      <<0::size(8)>>,
      <<0::size(8)>>
    ]

  def to_binary_message(%__MODULE__{status: :invalid_password, build: build}) when build > 6005,
    do: [
      <<Opcodes.logon_proof()::size(8)>>,
      <<Opcodes.logon_failed_incorrect_password()::size(8)>>,
      <<0::size(8)>>,
      <<0::size(8)>>
    ]

  def to_binary_message(%__MODULE__{status: :invalid_password}),
    do: [
      <<Opcodes.logon_proof()::size(8)>>,
      <<Opcodes.logon_failed_incorrect_password()::size(8)>>
    ]

  def to_binary_message(%__MODULE__{status: :invalid_build, build: build}) when build > 6005,
    do: [
      <<Opcodes.logon_challenge()::size(8)>>,
      <<Opcodes.logon_failed_version_invalid()::size(8)>>,
      <<0::size(8)>>,
      <<0::size(8)>>
    ]

  def to_binary_message(%__MODULE__{status: :invalid_build}),
    do: [
      <<Opcodes.logon_challenge()::size(8)>>,
      <<Opcodes.logon_failed_version_invalid()::size(8)>>
    ]
end
