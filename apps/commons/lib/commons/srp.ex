defmodule Commons.SRP do
  @moduledoc """
    An implementation of SRP version 6 client-server authentication.
  """

  require Logger

  @sha 160
  @version :"6"
  @generator <<7 :: size(8)>>
  @bits_size 256
  @bytes div(@bits_size, 8)

  def get_generator, do: @generator

  def gen_salt do
    Logger.debug "Generating a random 32 bit number"
    :crypto.strong_rand_bytes(@bytes)
  end

  def get_prime do
    <<0x894B645E89E1535BBDAD5B8B290650530801B18EBFBF5E8FAB3C82872A3E9BB7
        :: unsigned-big-integer-size(256)>>
  end

  def get_verifier(gen, prime, d_key) do
    Logger.debug "Getting a verifier: v = g^x"
    :crypto.mod_pow(gen, d_key, prime)
  end

  def get_derived_key(username, password, salt) do
    Logger.debug "Getting a derived key"
    norm_username = normalize_string(username)
    norm_password = normalize_string(password)
    hashed_up = hash([norm_username, ":", norm_password])
    
    [salt, hashed_up]
    |> hash() 
    |> from_l_to_b_endian(@sha)
  end

  def get_scrambler(b_public_client, b_public_server) do
    Logger.debug "Getting scrambler"
    l_public_client = from_b_to_l_endian(b_public_client, @bits_size)
    l_public_server = from_b_to_l_endian(b_public_server, @bits_size)
    hash([l_public_client, l_public_server]) |> from_l_to_b_endian(@sha)
  end

  @doc """
    Generates a {public, private} client key pair.
  """
  def client_public_private_key(gen, prime) do
    Logger.debug "Generating a public and private key for client"
    {public, private} = :crypto.generate_key(:srp, {:user, [gen, prime, @version]})
    case @bytes == byte_size(public) do
       true -> {public, private}
       false ->
        Logger.debug "Regenerating, public key size do not match #{@bytes}."
        client_public_private_key(gen, prime)
    end
  end

  @doc """
    Generates a {public, private} server key pair.
  """
  def server_public_private_key(ver) do
    Logger.debug "Generating a public and private key for server"
    gen = get_generator()
    prime = get_prime()
    {public, private} = :crypto.generate_key(:srp, {:host, [ver, gen, prime, @version]})
    case @bytes == byte_size(public) do
       true -> {public, private}
       false ->
        Logger.debug "Regenerating, public key size do not match #{@bytes}."
        server_public_private_key(ver)
    end
  end

  @doc """
    Computes the client session key.
  """
  def compute_client_key(private_client, public_server, public_client, gen, prime, d_key) do
    Logger.debug "Computing a client key."
    u = get_scrambler(public_client, public_server)
    :crypto.compute_key(:srp,
                        public_server,
                        {public_client, private_client},
                        {:user, [d_key, prime, gen, @version, u]})
  end

  @doc """
    Computes the server session key.
  """
  def compute_server_key(private_server, public_client, public_server, ver) do
    Logger.debug "Computing a server key."
    prime = get_prime()
    u = get_scrambler(public_client, public_server)
    key = :crypto.compute_key(:srp,
                              public_client,
                              {public_server, private_server},
                              {:host, [ver, prime, @version, u]})
    Logger.debug "Server key: #{Kernel.inspect(key)}"
    case @bytes == byte_size(key) do
      true -> key
      false ->
        Logger.debug "Regenerating, server key size do not match #{@bytes}."
        compute_server_key(private_server, public_client, public_server, ver)
    end

  end

  def interleave_hash(h) do
    l_h = from_b_to_l_endian(h, @bits_size)
    {odd, even} = separate_bytes(l_h, {[], []}, 0)
    hash_even = hash(even)
    hash_odd = hash(odd)
    combine_hashes(hash_odd, hash_even, [])
    |> :erlang.iolist_to_binary |> from_l_to_b_endian(@sha * 2)
  end

  def m1(username, l_salt, public_client, public_server, key) do
    Logger.debug("Calculating M1")
    prime = get_prime()
    l_prime = from_b_to_l_endian(prime, @bits_size)
    l_hash = hash(l_prime)
    b_hash = from_l_to_b_endian(l_hash, @sha)

    gen = get_generator()
    l_gen_hash = hash(gen)
    b_gen_hash = from_l_to_b_endian(l_gen_hash, @sha)

    p1 = :crypto.exor(b_hash, b_gen_hash)
    l_p1 = from_b_to_l_endian(p1, @sha)

    norm_username = normalize_string(username)
    hashed_username = hash(norm_username)

    l_public_server = from_b_to_l_endian(public_server, @bits_size)
    l_public_client = from_b_to_l_endian(public_client, @bits_size)
    l_key = from_b_to_l_endian(key, 2 * @sha)

    [l_p1,
     hashed_username,
     l_salt,
     l_public_client,
     l_public_server,
     l_key] |> hash |> from_l_to_b_endian(@sha)
  end

  def m2(public_client, m1, key) do
    Logger.debug("Calculating m2")
    l_public_client = from_b_to_l_endian(public_client, @bits_size)
    l_key = from_b_to_l_endian(key, 2 * @sha)
    l_m1 = from_b_to_l_endian(m1, @sha)

    [l_public_client, l_m1, l_key]
    |> hash() 
    |> from_l_to_b_endian(@sha)
  end

  @doc """
    Normalize all strings (put them all in CAPS)
  """
  def normalize_string(val), do: String.upcase(val)


  # Separate bytes by {odd, even}.
  defp separate_bytes(<<>>, data, _n), do: data
  defp separate_bytes(<<b :: size(8), rest :: binary>>, {odd, even}, n) do
    case rem(n, 2) == 0 do
      true ->  separate_bytes(rest, {odd, even ++ [b]}, n+1) # even number
      false -> separate_bytes(rest, {odd ++ [b], even}, n+1) # odd number
    end
  end

  # Combines two hashes (odd, even).
  defp combine_hashes(<<>>, <<>>, data), do: Enum.reverse(data)
  defp combine_hashes(<<odd  :: size(8), odd_rest  :: binary>>,
                      <<even :: size(8), even_rest :: binary>>,
                      data) do
    combine_hashes(odd_rest, even_rest, [odd | [even | data]])
  end

  defp hash(val), do: :crypto.hash(:sha, val)

  def from_l_to_b_endian(val, size) do
    << n :: unsigned-little-integer-size(size)>> = val
    << n :: unsigned-big-integer-size(size)>>
  end

  def from_b_to_l_endian(val, size) do
    << n :: unsigned-big-integer-size(size)>> = val
    << n :: unsigned-little-integer-size(size)>>
  end

end
