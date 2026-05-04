defmodule Realmd.Messages.Realmlist.Realm do
  @moduledoc """
  Builds the binary representation of a single realm entry for the realm list packet.
  """

  alias Shared.Data.CharacterHandler
  alias Shared.Data.Schemas.Account
  alias Shared.Data.Schemas.Realm, as: DBRealm

  defstruct [
    :icon,
    :realm_flags,
    :name,
    :address,
    :population_level,
    :amount_of_characters,
    :timezone
  ]

  @spec build(DBRealm.t(), Account.t()) :: list()
  def build(db_realm = %DBRealm{}, account = %Account{}) do
    num_chars = CharacterHandler.count_by_account(account)

    [
      <<db_realm.icon::little-size(32)>>,
      <<db_realm.realmflags::size(8)>>,
      [db_realm.name, <<0>>],
      [db_realm.address, ":", Enum.map(Integer.digits(db_realm.port), &to_string/1), <<0>>],
      <<db_realm.population::little-float-size(32)>>,
      <<num_chars::size(8)>>,
      <<db_realm.timezone::size(8)>>,
      <<db_realm.id::size(8)>>
    ]
  end
end
