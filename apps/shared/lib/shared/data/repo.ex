defmodule Shared.Data.Repo do
  use Ecto.Repo,
    otp_app: :shared,
    adapter: Ecto.Adapters.Postgres
end
