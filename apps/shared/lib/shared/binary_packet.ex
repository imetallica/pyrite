defprotocol Shared.BinaryPacket do
  @moduledoc """
  A protocol that all server packets should implement.
  """
  @spec to_binary(packet :: t()) :: binary() | [binary()]
  def to_binary(packet)
end
