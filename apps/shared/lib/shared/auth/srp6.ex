defmodule Shared.Auth.SRP6 do
  @moduledoc """
  Secure Remote Password 6 (SRP-6) protocol implementation.
  """
  alias Shared.BinaryData

  require Logger

  @bits_size 256
  @bytes div(@bits_size, 8)
  @generator <<7::size(8)>>
  @prime <<0x894B645E89E1535BBDAD5B8B290650530801B18EBFBF5E8FAB3C82872A3E9BB7::unsigned-big-integer-size(
             256
           )>>
  @sha 160
  @version :"6"

  @little_endian_prime BinaryData.to_little_endian(@prime, @bits_size)
  @big_endian_prime_hash BinaryData.to_big_endian(:crypto.hash(:sha, @little_endian_prime), @sha)
  @big_endian_generator_hash BinaryData.to_big_endian(:crypto.hash(:sha, @generator), @sha)
  @little_endian_p1 BinaryData.to_little_endian(
                      :crypto.exor(@big_endian_prime_hash, @big_endian_generator_hash),
                      @sha
                    )

  def verifier(key), do: :crypto.mod_pow(@generator, key, @prime)

  @compile {:inline, prime: 0}
  def prime, do: @prime

  @compile {:inline, salt: 0}
  def salt, do: :crypto.strong_rand_bytes(@bytes)

  @compile {:inline, generator: 0}
  def generator, do: @generator

  def derived_key(username, password, salt) do
    username = String.upcase(username)
    password = String.upcase(password)
    hashed_user_pass = :crypto.hash(:sha, [username, ":", password])
    hashed_salt_user_pass = :crypto.hash(:sha, [salt, hashed_user_pass])
    BinaryData.to_big_endian(hashed_salt_user_pass, @sha)
  end

  def scrambler(big_endian_public_client, big_endian_public_server) do
    [
      BinaryData.to_little_endian(big_endian_public_client, @bits_size),
      BinaryData.to_little_endian(big_endian_public_server, @bits_size)
    ]
    |> then(fn data -> :crypto.hash(:sha, data) end)
    |> BinaryData.to_big_endian(@sha)
  end

  def generate_public_and_private_key_for_client(generator, prime) do
    case :crypto.generate_key(:srp, {:user, [generator, prime, @version]}) do
      {public, private} when byte_size(public) === @bytes ->
        {public, private}

      _ ->
        Logger.debug("Regenerating client keys, it does not match the expected size = #{@bytes}.")

        generate_public_and_private_key_for_client(generator, prime)
    end
  end

  def generate_public_and_private_key_for_server(ver) do
    case :crypto.generate_key(:srp, {:host, [ver, @generator, @prime, @version]}) do
      {public, private} when byte_size(public) === @bytes ->
        {public, private}

      _ ->
        Logger.debug("Regenerating server keys, it does not match the expected size = #{@bytes}.")

        generate_public_and_private_key_for_server(ver)
    end
  end

  def compute_client_session_key(
        client_private_key,
        client_public_key,
        server_public_key,
        generator,
        prime,
        derived_key
      ) do
    :crypto.compute_key(
      :srp,
      server_public_key,
      {client_public_key, client_private_key},
      {:user,
       [derived_key, prime, generator, @version, scrambler(client_public_key, server_public_key)]}
    )
  end

  def compute_server_session_key(
        server_private_key,
        server_public_key,
        client_public_key,
        verifier
      ) do
    case :crypto.compute_key(
           :srp,
           client_public_key,
           {server_public_key, server_private_key},
           {:host, [verifier, @prime, @version, scrambler(client_public_key, server_public_key)]}
         ) do
      key when byte_size(key) === @bytes ->
        key

      _ ->
        compute_server_session_key(
          server_private_key,
          server_public_key,
          client_public_key,
          verifier
        )
    end
  end

  def interleave_hash(hash) do
    hash
    |> BinaryData.to_little_endian(@bits_size)
    |> separate_bytes({[], []}, 0)
    |> then(fn {odd, even} ->
      combine_hashes(:crypto.hash(:sha, odd), :crypto.hash(:sha, even), [])
    end)
    |> :erlang.iolist_to_binary()
    |> BinaryData.to_big_endian(@sha * 2)
  end

  def m1(username, salt, client_public_key, server_public_key, session_key) do
    Logger.debug("Generating M1...")

    hashed_username = :crypto.hash(:sha, String.upcase(username))
    little_endian_server_public_key = BinaryData.to_little_endian(server_public_key, @bits_size)
    little_endian_client_public_key = BinaryData.to_little_endian(client_public_key, @bits_size)
    little_endian_session_key = BinaryData.to_little_endian(session_key, @sha * 2)

    [
      @little_endian_p1,
      hashed_username,
      salt,
      little_endian_client_public_key,
      little_endian_server_public_key,
      little_endian_session_key
    ]
    |> then(&:crypto.hash(:sha, &1))
    |> BinaryData.to_big_endian(@sha)
  end

  def m2(client_public_key, m1, session_key) do
    Logger.debug("Generating M2...")

    little_endian_client_public_key = BinaryData.to_little_endian(client_public_key, @bits_size)
    little_endian_m1 = BinaryData.to_little_endian(m1, @sha)
    little_endian_session_key = BinaryData.to_little_endian(session_key, @sha * 2)

    [
      little_endian_client_public_key,
      little_endian_m1,
      little_endian_session_key
    ]
    |> then(&:crypto.hash(:sha, &1))
    |> BinaryData.to_big_endian(@sha)
  end

  defp separate_bytes(<<>>, {odd, even}, _), do: {Enum.reverse(odd), Enum.reverse(even)}

  defp separate_bytes(<<b::size(8), rest::binary>>, {odd, even}, n) when rem(n, 2) === 0,
    do: separate_bytes(rest, {odd, [b | even]}, n + 1)

  defp separate_bytes(<<b::size(8), rest::binary>>, {odd, even}, n),
    do: separate_bytes(rest, {[b | odd], even}, n + 1)

  defp combine_hashes(<<>>, <<>>, data), do: Enum.reverse(data)

  defp combine_hashes(
         <<odd::size(8), odd_rest::binary>>,
         <<even::size(8), even_rest::binary>>,
         data
       ) do
    combine_hashes(odd_rest, even_rest, [odd | [even | data]])
  end
end
