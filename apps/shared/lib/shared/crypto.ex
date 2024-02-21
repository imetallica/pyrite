defmodule Shared.Crypto do
  @moduledoc """
  Encryption and decryption of packets.
  """
  require Logger

  import Bitwise

  @spec decrypt(packet :: [binary()], salt :: binary() | non_neg_integer()) :: binary()
  def decrypt(packet, salt) when is_list(packet) and is_binary(salt) do
    decrypt(Enum.join(packet, <<>>), {0, :erlang.binary_to_list(salt)}, <<>>)
  end

  def decrypt(packet, salt) when is_list(packet) and is_integer(salt) do
    decrypt(Enum.join(packet, <<>>), {0, Integer.digits(salt)}, <<>>)
  end

  defp decrypt(<<>>, _, acc), do: acc

  defp decrypt(<<old_byte::size(8), rest::binary>>, {j, [head | tail]}, acc) do
    new_byte = bxor(old_byte, j) - head

    decrypt(rest, {new_byte, tail}, <<acc::binary, new_byte::size(8)>>)
  end

  @spec encrypt(packet :: [binary()], salt :: binary() | non_neg_integer()) :: binary()
  def encrypt(packet, salt) when is_list(packet) and is_binary(salt) do
    encrypt(Enum.join(packet, <<>>), {0, :erlang.binary_to_list(salt)}, <<>>)
  end

  def encrypt(packet, salt) when is_list(packet) and is_integer(salt) do
    encrypt(Enum.join(packet, <<>>), {0, Integer.digits(salt)}, <<>>)
  end

  defp encrypt(<<>>, _, acc), do: acc

  defp encrypt(<<old_byte::size(8), rest::binary>>, {j, [head | tail]}, acc) do
    new_byte = bxor(head, old_byte) + j

    encrypt(rest, {new_byte, tail}, <<acc::binary, new_byte::size(8)>>)
  end
end
