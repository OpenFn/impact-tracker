defmodule ImpactTracker.Repo do
  use Ecto.Repo,
    otp_app: :impact_tracker,
    adapter: Ecto.Adapters.Postgres

  @impl true
  def init(_type, config) do
    {:ok, Keyword.put(config, :url, System.get_env("DATABASE_URL"))}
  end
end
