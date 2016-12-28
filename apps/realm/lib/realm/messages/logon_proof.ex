defmodule Realm.Messages.LogonProof do
  @moduledoc """

  This module is responsible for handling the second step of the authentication
  between client and server.

  These functions only are called if, the first step of authentication was successful.

  -----------------------------------------------------------------------------------
  TODO: In this step, add support for checking WoW client version and patch handling.
  -----------------------------------------------------------------------------------

  """

  require Logger
  use Commons.Codes.AuthCodes
  alias Commons.{SRP, Models.Account}
  alias Realm.Messages.LogonProof

  defstruct [client_public_key: :nil, client_m1: :nil, session_key: :nil,
             password_status: :nil, m2: :nil]

  @type client_proof_message :: binary
  @type required_server_key_variables :: %{server_public_key: binary,
                                           server_private_key: binary,
                                           account_verifier: binary}
  @type required_check_pass_variables :: %{account_identity: String.t,
                                           account_salt: binary,
                                           server_public_key: binary}
  @type socket :: pid


  @spec get_proof(client_proof_message) :: %LogonProof{
                                              client_public_key: binary,
                                              client_m1: binary}

  @doc """
  Parses a proof message sent from client.

  Before returning, all values are converted from little-endian to big-endian.
  """
  def get_proof(msg) do
    Logger.debug "Getting the logon proof"
    <<l_public_client :: unsigned-little-integer-size(256),
      l_m1            :: unsigned-little-integer-size(160),
      _crc_hash       :: unsigned-little-integer-size(160),
      _num_keys       :: size(8),
      _unk            :: size(8)>> = msg

    Logger.debug "Filtering the logon proof"
    b_m1 = <<l_m1 :: unsigned-big-integer-size(160)>>
    b_public_client = <<l_public_client :: unsigned-big-integer-size(256)>>
    %LogonProof{client_public_key: b_public_client, client_m1: b_m1}
  end

  @spec compute_server_key(
    %LogonProof{client_public_key: binary, client_m1: binary},
    required_server_key_variables) :: %LogonProof{client_public_key: binary,
                                                  client_m1: binary,
                                                  session_key: binary}
  @doc """
  Computes a server key, that will be sent back to the client, so it can
  be shared with the game server for proper authentication when the client
  connect with the game server.

  Before returning the key, it is converted to little-endian from big-endian.
  """
  def compute_server_key(lp, fsv) do
    Logger.debug "Computing server key"
    server_key = SRP.compute_server_key(fsv.server_private_key,
                                        lp.client_public_key,
                                        fsv.server_public_key,
                                        fsv.account_verifier)
    key = SRP.interleave_hash(server_key)
    l_key = SRP.from_b_to_l_endian(key, 320)
    %{lp | session_key: l_key}
  end

  @spec check_password(
    %LogonProof{client_public_key: binary,
                client_m1: binary,
                session_key: binary},
    required_check_pass_variables) :: %LogonProof{}
  @doc """
  Checks if the password stored on the database is the same as the one sent
  by the client. Also saves into the database the session key.
  """
  def check_password(lp, fsv) do
    Logger.debug "Checking password"
    server_m1 = SRP.m1(fsv.account_identity,
                       fsv.account_salt,
                       lp.client_public_key,
                       fsv.server_public_key,
                       SRP.from_l_to_b_endian(lp.session_key, 320))
    case server_m1 == lp.client_m1 do
      false ->
        Logger.debug "Client has sent incorrect password."
        %{lp | password_status: :incorrect}

      true ->
        Logger.debug "Passwords match!"
        b_m2 = SRP.m2(lp.client_public_key, server_m1, lp.session_key)
        l_m2 = SRP.from_b_to_l_endian(b_m2, 160)

        Logger.debug "Saving the client session key"
        Account.set_session_key(fsv.account_identity, lp.session_key)

        %{lp | password_status: :correct, m2: l_m2}
    end
  end

  @spec send_response(%LogonProof{}, socket) :: %LogonProof{}
  @doc """
  Sends a message depending on the status of the `LogonProof` struct.
  """
  def send_response(lp, socket) do
    msg = [<<@cmd_auth_logon_proof :: size(8)>>] ++ to_socket(lp.password_status, lp)
    :gen_tcp.send(socket, msg)
    lp
  end

  defp to_socket(:incorrect, _lp) do
  [<<@wow_fail_incorrect_password :: size(8)>>]
  end

  defp to_socket(:correct, lp) do
    [<<@wow_success :: size(8)>>, lp.m2, <<0 :: size(8)>>,
     <<0 :: size(8)>>, <<0 :: size(8)>>]
  end

end
