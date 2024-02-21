defmodule Realmd.Messages.Realmlist.Realm do
  alias Data.Schemas.Realm, as: DBRealm

  defstruct [
    :icon,
    :realm_flags,
    :name,
    :address,
    :population_level,
    :amount_of_characters,
    :timezone
  ]

  def build(db_realm = %DBRealm{}),
    do: [
      <<db_realm.icon::little-size(32)>>,
      <<db_realm.realmflags::size(8)>>,
      [db_realm.name, <<0>>],
      [db_realm.address, ":", Enum.map(Integer.digits(db_realm.port), &to_string/1), <<0>>],
      <<db_realm.population::little-float-size(32)>>,
      # TODO: Implement this when we have support for characters.
      <<0::size(8)>>,
      <<db_realm.timezone::size(8)>>,
      <<db_realm.id::size(8)>>
    ]
end
