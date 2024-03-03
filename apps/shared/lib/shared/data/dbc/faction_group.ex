defmodule Shared.Data.Dbc.FactionGroup do
  @moduledoc """
  FactionGroup data.
  """
  alias Shared.Data.Dbc.TranslatableString

  use Ecto.Schema

  @primary_key {:id, :id, []}
  embedded_schema do
    field(:mask_id, :integer)
    embeds_one(:name, TranslatableString)
  end

  def player, do: %__MODULE__{id: 1, mask_id: 0}

  def alliance, do: %__MODULE__{id: 2, mask_id: 1, name: %TranslatableString{en: "Alliance"}}

  def horde, do: %__MODULE__{id: 3, mask_id: 2, name: %TranslatableString{en: "Horde"}}

  def monster, do: %__MODULE__{id: 4, mask_id: 3}
end
