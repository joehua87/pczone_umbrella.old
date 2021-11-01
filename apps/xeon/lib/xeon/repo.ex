defmodule Xeon.Repo do
  use Ecto.Repo,
    otp_app: :xeon,
    adapter: Ecto.Adapters.Postgres
end
