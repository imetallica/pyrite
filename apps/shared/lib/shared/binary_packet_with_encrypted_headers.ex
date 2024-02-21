defprotocol Shared.BinaryPacketWithEncryptedHeaders do
  @moduledoc """
  A protocol that all server packets should implement.
  """
  @spec to_binary(packet :: t(), encryption_key :: term()) :: binary() | [binary()]
  def to_binary(packet, encryption_key)
end
