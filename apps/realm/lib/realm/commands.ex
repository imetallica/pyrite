defmodule Realm.Commands do
  @moduledoc """
    These are the available commands from your Realm shell.
    This is an Elixir shell - if you are familiar with Elixir -
    you know what you are doing. If you are not, please read
    down below with *EXTREME* care.

    Please note that, you can call *any* public function
    from *any* module, but that is discouraged. Prefer this
    tool if you need to manage your Realm server.

    To manage your Game server, you should connect to it,
    instead. Realm is just responsible for the accounts and
    nothing else.
  """

  alias Commons.Models.Account

  @doc """
  Creates a new account:

  `username`, `password` and `email` are both `Strings`

  ```create_account!(username, password, email)```
  """
  def create_account!(username, password, email) do
    Account.create!(username, password, email)
  end

  @doc """
  Bans the account with `username`.
  """
  def permaban!(username), do: Account.ban!(username, :permanent)

  @doc """
  Suspends the account with `username` until `YYYY-MM-DD HH:MM:SS`.
  """
  def suspend!(username, time), do: Account.ban!(username, :temporary, time)

  @doc """
  Removes the ban/suspension of account with `username`.
  """
  def unban!(username), do: Account.unban!(username)

  @doc """
  Shows the memory usage of the system.
  """
  def memory_usage, do: "Total memory usage: #{:erlang.memory[:total] / 1000000} MB"
  
end