defmodule Realmd.Messages.Realmlist do
  @moduledoc """
  Module responsible for handling the realmlist message.
  """
  alias Realmd.Socket.Acceptor
  alias Data.RealmHandler
  alias Realmd.Messages.Realmlist.Realm
  alias Realmd.Socket.Opcodes
  require Logger

  defstruct [:account, :realms, :status, :build]

  def fetch_realmlist(acceptor = %Acceptor{}) do
    Logger.debug("Fetching realmlist for account: #{acceptor.account.username}.")

    realms = RealmHandler.allowed_realmlist(acceptor.account)

    {:ok,
     %__MODULE__{
       status: :ok,
       account: acceptor.account,
       build: acceptor.build,
       realms: Enum.map(realms, &Realm.build/1)
     }}
  end

  def to_binary_message(%__MODULE__{status: :ok, realms: realms}) do
    number_of_realms = Enum.count(realms)
    number_of_realms = <<number_of_realms::unsigned-little-integer-size(8)>>

    size =
      byte_size(
        realms
        |> List.flatten()
        |> Enum.join(<<>>)
        |> Kernel.<>(<<0::size(32)>> <> number_of_realms <> <<0::size(16)>>)
      )

    [
      <<Opcodes.realmlist()::size(8)>>,
      <<size::unsigned-little-integer-size(16)>>,
      <<0::size(32)>>,
      number_of_realms,
      realms,
      <<0::size(16)>>
    ]
  end
end
