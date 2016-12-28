defmodule Realm.Messages.LogonChallenge do
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

  defstruct [id_len: :nil,
             identity: :nil,
             build: :nil,
             account: :nil,
             status: :nil,
             server_public_key: :nil,
             server_private_key: :nil]

  require Logger
  use Commons.Codes.AuthCodes
  alias Commons.{Models.Account, SRP}
  alias Realm.{Errors.UsernameSizeError, Messages.LogonChallenge}

  @type client_logon_message :: binary
  @type account_status :: :account_not_found
                        | :account_not_banned
                        | :account_suspended
                        | :account_banned
  @type socket :: pid

  @spec get_and_check_identity(client_logon_message)
    :: no_return | %LogonChallenge{id_len: integer,
                                   identity: String.t,
                                   build: integer}
  @doc """
    Gets the incoming packet, extracts it's fields and checks if the length of the
    identity is the same as the length sent from the client. It raises in the case
    they are different or the identity length is zero.
  """
  def get_and_check_identity(msg) do
    Logger.debug "Getting the logon message"

    <<_err       :: size(8),
      _size      :: unsigned-little-integer-size(16),
      _game_name :: unsigned-little-integer-size(32),
      _v1        :: size(8),
      _v2        :: size(8),
      _v3        :: size(8),
      build      :: unsigned-little-integer-size(16),
      _platform  :: unsigned-little-integer-size(32),
      _os        :: unsigned-little-integer-size(32),
      _country   :: unsigned-little-integer-size(32),
      _tz_bias   :: unsigned-little-integer-size(32),
      _ip        :: unsigned-little-integer-size(32),
      id_len     :: size(8),
      identity   :: binary>> = msg

    Logger.debug "Checking the logon message"

    if id_len == 0 do
      raise UsernameSizeError
    end

    if String.length(identity) != id_len do
      raise UsernameSizeError,
        "The size of the username(#{String.length(identity)}) is different
                                from the one received(#{id_len})."
    end

    %LogonChallenge{id_len: id_len, identity: identity, build: build}
  end

  @spec bootstrap_identity(
    %LogonChallenge{id_len: integer, identity: String.t, build: integer})
      :: %LogonChallenge{id_len: integer,
                         identity: String.t,
                         build: integer,
                         status: :account_not_found}
       | %LogonChallenge{id_len: integer,
                         identity: String.t,
                         build: integer,
                         status: :account_suspended}
       | %LogonChallenge{id_len: integer,
                         identity: String.t,
                         build: integer,
                         status: :account_banned}
       | %LogonChallenge{id_len: integer,
                         identity: String.t,
                         build: integer,
                         account: %Account{},
                         server_public_key: binary,
                         server_private_key: binary,
                         status: :account_not_banned}

  @doc """
    Checks the database for the informed identity and generates a response ready to be sent
    back to the client.

    If it doesn't have records, it will return the `LogonChallenge` struct
    with `status: :account_not_found`.

    If the account is banned, it will return the `LogonChallenge` struct
    with `status: :account_suspended` or `status: :account_banned`,
    depending on the status of the ban.

    If the account is not banned, it will calculate the servers public and private keys and
    return the `LogonChallenge` struct with `status: :account_not_banned, account: %Account{},
    server_public_key: <<...>>, server_private_key: <<...>>`.
  """
  def bootstrap_identity(lc) do
    Logger.debug "Checking database"
    case Account.get_by_username(lc.identity) do
      :nil ->
        Logger.info "No account found (#{lc.identity})"
        %{lc | status: :account_not_found}

      account ->
        Logger.info "Account found (#{lc.identity})"
        case Account.banned?(account) do
          :suspended ->
            Logger.info "Suspended account #{lc.identity} tried to login."
            %{lc | status: :account_suspended}

          :banned ->
            Logger.info "Banned account #{lc.identity} tried to login."
            %{lc | status: :account_banned}

          :not_banned ->
            Logger.info "Account #{lc.identity} logging in."
            {public_server, private_server} = SRP.server_public_private_key(account.verifier)
            %{lc | status: :account_not_banned,
                   account: account,
                   server_public_key: public_server,
                   server_private_key: private_server}
        end
    end
  end


  @spec send_response(%LogonChallenge{}, socket) :: %LogonChallenge{}
  @doc """
  Sends a message depending on the status of the `LogonChallenge` struct.
  """
  def send_response(lc, socket) do
   msg = [<<@cmd_auth_logon_challenge :: size(8)>>, <<0 :: size(8)>>] ++ to_socket(lc.status, lc)
   :gen_tcp.send(socket, msg)
   lc
  end

  # Account not found
  defp to_socket(:account_not_found, _lc), do: [<<@wow_fail_unknown_account :: size(8)>>]

  # Account banned
  defp to_socket(:account_banned,  _lc), do: [<<@wow_fail_banned :: size(8)>>]

  # Account suspended
  defp to_socket(:account_suspended, _lc), do: [<<@wow_fail_suspended :: size(8)>>]

  # Account found and not banned response.
  defp to_socket(:account_not_banned, lc) do
    gen_length = byte_size(SRP.get_generator())
    prime_length = byte_size(SRP.get_prime())
    unk3 = <<0x0123456789ABCDEF :: unsigned-little-integer-size(128)>>
    l_public_server = SRP.from_b_to_l_endian(lc.server_public_key, 256)
    l_prime = SRP.from_b_to_l_endian(SRP.get_prime(), 256)
    l_salt = lc.account.salt      # Already little endian
    l_gen = SRP.get_generator()   # Same value in both endians (big and little)

    [<<@wow_success :: size(8)>>, l_public_server, <<gen_length :: size(8)>>, l_gen, <<prime_length :: size(8)>>,
     l_prime, l_salt, unk3, <<0 :: size(8)>>]
  end

end
