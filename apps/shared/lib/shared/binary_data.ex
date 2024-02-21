defmodule Shared.BinaryData do
  @moduledoc """
  Functions for working with binary data.
  """

  def to_little_endian(big, size) do
    <<n::unsigned-big-integer-size(size)>> = big
    <<n::unsigned-little-integer-size(size)>>
  end

  def to_big_endian(little, size) do
    <<n::unsigned-little-integer-size(size)>> = little
    <<n::unsigned-big-integer-size(size)>>
  end
end
