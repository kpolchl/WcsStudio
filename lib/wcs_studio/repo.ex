defmodule WcsStudio.Repo do
  use Ecto.Repo,
    otp_app: :wcs_studio,
    adapter: Ecto.Adapters.Postgres
end
