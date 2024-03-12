defmodule Shared.Crypto do
  @moduledoc """
  Encryption and decryption of packets.
  """
  alias Shared.Crypto.Keystate
  require Logger

  import Bitwise

  @spec decrypt(
          packet :: binary(),
          salt :: binary(),
          key_state :: Keystate.t()
        ) :: {binary(), Keystate.t()}

  def decrypt(<<encrypted_header::binary-size(6), body::binary>>, salt, key_state)
      when is_binary(salt) do
    Logger.debug(
      "Decrypting header #{inspect(encrypted_header)} with size #{byte_size(encrypted_header)} and key state of #{inspect(key_state)}."
    )

    {header, new_key_state} =
      do_decrypt(
        :binary.bin_to_list(encrypted_header),
        {key_state, :binary.bin_to_list(salt)},
        <<>>
      )

    Logger.debug(
      "Decrypted header: #{inspect(header)} with size #{byte_size(header)} and new key state of #{inspect(new_key_state)}."
    )

    {header <> body, new_key_state}
  end

  defp do_decrypt([], {key_state, _}, acc), do: {acc, key_state}

  defp do_decrypt(
         [old_byte | rest],
         {%Keystate{key_index: idx, key_state: key_state}, session_key},
         acc
       ) do
    new_byte = band(bxor(old_byte - key_state, Enum.at(session_key, idx)), 255)
    new_idx = rem(idx + 1, length(session_key))
    Logger.debug("Decrypting: #{inspect(old_byte)} -> #{inspect(new_byte)}.")

    do_decrypt(
      rest,
      {%Keystate{key_index: new_idx, key_state: old_byte}, session_key},
      <<acc::binary, new_byte::size(8)>>
    )
  end

  @spec encrypt(
          packet :: [binary()],
          salt :: binary(),
          key_state :: Keystate.t()
        ) :: {binary(), Keystate.t()}

  def encrypt([h1, h2], salt, key_state) when is_binary(salt) do
    header = h1 <> h2

    Logger.debug(
      "Encrypting header #{inspect(header)} with salt #{inspect(salt)} and key state #{inspect(key_state)}."
    )

    do_encrypt(:binary.bin_to_list(header), {key_state, :binary.bin_to_list(salt)}, <<>>)
  end

  defp do_encrypt([], {key_state, _}, acc), do: {acc, key_state}

  defp do_encrypt(
         [old_byte | rest],
         {%Keystate{key_index: idx, key_state: key_state}, session_key},
         acc
       ) do
    new_byte = band(bxor(old_byte, Enum.at(session_key, idx)) + key_state, 255)
    new_idx = rem(idx + 1, length(session_key))

    Logger.debug("Encrypting: #{inspect(old_byte)} -> #{inspect(new_byte)}.")

    do_encrypt(
      rest,
      {%Keystate{key_index: new_idx, key_state: new_byte}, session_key},
      <<acc::binary, new_byte::size(8)>>
    )
  end
end
