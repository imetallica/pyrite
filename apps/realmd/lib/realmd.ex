defmodule Realmd do
  @moduledoc """
  This module exposes commands you can send to the realmd server via its console.
  """
  alias Shared.Data.AccountHandler

  def create_account(username, password) when is_binary(username) and is_binary(password) do
    AccountHandler.create_account(%{username: username, password: password})
  end
end
