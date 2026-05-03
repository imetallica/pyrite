defmodule Shared.Auth.GameProof do
  @moduledoc """
  Game server authentication proof verification.

  During CMSG_AUTH_SESSION, the client sends a SHA-1 digest proving it knows
  the session key established during realmd's SRP6 exchange. This module
  computes the expected digest for comparison.
  """

  alias Shared.BinaryData

  @session_key_bits 320

  @doc """
  Computes the expected proof digest for the given auth parameters.

  The digest is SHA-1 of:
    username (uppercase, raw bytes)
    || 0x00000000 (4 bytes LE)
    || client_seed (4 bytes LE)
    || server_seed (4 bytes LE)
    || session_key (40 bytes LE)
  """
  @spec compute_digest(
          session_key :: binary(),
          username :: String.t(),
          client_seed :: non_neg_integer(),
          server_seed :: non_neg_integer()
        ) :: binary()
  def compute_digest(session_key, username, client_seed, server_seed) do
    session_key_le = BinaryData.to_little_endian(session_key, @session_key_bits)

    :crypto.hash(:sha, [
      String.upcase(username),
      <<0::unsigned-little-integer-size(32)>>,
      <<client_seed::unsigned-little-integer-size(32)>>,
      <<server_seed::unsigned-little-integer-size(32)>>,
      session_key_le
    ])
  end

  @doc """
  Verifies the client's proof against the expected digest using constant-time comparison.
  """
  @spec verify?(
          session_key :: binary(),
          username :: String.t(),
          client_seed :: non_neg_integer(),
          server_seed :: non_neg_integer(),
          client_proof :: binary()
        ) :: boolean()
  def verify?(session_key, username, client_seed, server_seed, client_proof) do
    expected = compute_digest(session_key, username, client_seed, server_seed)
    :crypto.hash_equals(expected, client_proof)
  end
end
