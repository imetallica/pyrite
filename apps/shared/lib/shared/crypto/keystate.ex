defmodule Shared.Crypto.Keystate do
  @moduledoc """
  Tracks the evolving state of packet encryption/decryption keys.
  """

  defstruct key_state: 0, key_index: 0

  @type t() :: %__MODULE__{
          key_state: non_neg_integer(),
          key_index: non_neg_integer()
        }

  @spec new() :: t()
  def new, do: %__MODULE__{}
end
