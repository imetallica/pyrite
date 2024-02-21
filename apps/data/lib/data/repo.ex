defmodule Data.Repo do
  use Ecto.Repo,
    otp_app: :data,
    adapter: Ecto.Adapters.Postgres
end
