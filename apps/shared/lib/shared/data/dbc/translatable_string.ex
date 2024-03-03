defmodule Shared.Data.Dbc.TranslatableString do
  @moduledoc """
  Translations.
  """
  use Ecto.Schema

  @primary_key false
  embedded_schema do
    field(:en, :string)
    field(:kr, :string)
    field(:fr, :string)
    field(:de, :string)
    field(:cn, :string)
    field(:tw, :string)
    field(:es, :string)
    field(:mx, :string)
  end
end
