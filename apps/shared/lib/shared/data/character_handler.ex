defmodule Shared.Data.CharacterHandler do
  @moduledoc """
  Module responsible for handling character related operations
  """
  alias Shared.Data.Repo
  alias Shared.Data.Schemas.Account
  alias Shared.Data.Schemas.Character

  import Ecto.Query

  @spec all(Account.t()) :: list(Character.t())
  def all(%Account{id: id}) do
    query =
      from(c in Character,
        where: c.account_id == ^id,
        preload: [:pets]
      )

    Repo.all(query)
  end
end
