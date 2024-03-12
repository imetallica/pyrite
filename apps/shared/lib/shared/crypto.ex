defmodule Shared.Crypto do
  @moduledoc """
  Encryption and decryption of packets.
  """
  require Logger

  import Bitwise

  @spec decrypt(packet :: binary(), salt :: binary() | non_neg_integer()) :: binary()
  def decrypt(<<encrypted_header::binary-size(6), body::binary>>, salt) when is_binary(salt) do
    Logger.debug(
      "Decrypting header #{inspect(encrypted_header)} with size #{byte_size(encrypted_header)}."
    )

    header =
      do_decrypt(:binary.bin_to_list(encrypted_header), {0, :binary.bin_to_list(salt)}, <<>>)

    Logger.debug("Decrypted header: #{inspect(header)} with size #{byte_size(header)}.")

    header <> body
  end

  def decrypt(<<encrypted_header::binary-size(6), body::binary>>, salt) when is_integer(salt) do
    Logger.debug(
      "Decrypting header #{inspect(encrypted_header)} with size #{byte_size(encrypted_header)}."
    )

    header =
      do_decrypt(
        :binary.bin_to_list(encrypted_header),
        {0, :binary.bin_to_list(to_string(salt))},
        <<>>
      )

    Logger.debug("Decrypted header: #{inspect(header)} with size #{byte_size(header)}.")

    header <> body
  end

  defp do_decrypt([], _, acc), do: acc

  defp do_decrypt(
         [old_byte | rest],
         {j, [head | tail]},
         acc
       ) do
    new_byte = bxor(old_byte - j, head)

    Logger.debug(
      "Decrypting: #{inspect(old_byte)} -> #{inspect(new_byte)}, #{inspect(j)}, #{inspect(head)}."
    )

    do_decrypt(rest, {old_byte, tail}, <<acc::binary, new_byte::size(8)>>)
  end

  @spec encrypt(
          packet :: [binary()],
          salt :: binary() | non_neg_integer(),
          j :: integer()
        ) :: binary()
  def encrypt(packet, salt, j \\ 0)

  def encrypt([h1, h2], salt, j) when is_binary(salt) do
    header = h1 <> h2
    Logger.debug("Encrypting header #{inspect(header)} with salt #{inspect(salt)}.")

    do_encrypt(:binary.bin_to_list(header), {j, :binary.bin_to_list(salt)}, <<>>)
  end

  def encrypt([h1, h2], salt, j) when is_integer(salt) do
    header = h1 <> h2
    Logger.debug("Encrypting header #{inspect(header)} with size #{byte_size(header)}.")

    do_encrypt(
      :binary.bin_to_list(header),
      {j, :binary.bin_to_list(Integer.to_string(salt))},
      <<>>
    )
  end

  defp do_encrypt([], _, acc), do: acc

  defp do_encrypt(
         [old_byte | rest],
         {j, [head | tail]},
         acc
       ) do
    new_byte = bxor(old_byte, head) + j

    Logger.debug(
      "Encrypting: #{inspect(old_byte)} -> #{inspect(new_byte)}, #{inspect(j)}, #{inspect(head)}."
    )

    do_encrypt(rest, {new_byte, tail}, <<acc::binary, new_byte::size(8)>>)
  end
end
