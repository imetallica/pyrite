defmodule Shared.Data.Base.BasePlayer.ClassStats do
  @moduledoc """
  This module represents the stats of a player.
  """
  use Ecto.Schema

  @primary_key false
  embedded_schema do
    field(:base_health, :integer, default: 0)
    field(:base_mana, :integer, default: 0)
  end
end
