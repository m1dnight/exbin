defmodule Exbin.Repo do
  use Ecto.Repo,
    otp_app: :exbin,
    adapter: Ecto.Adapters.Postgres
end
