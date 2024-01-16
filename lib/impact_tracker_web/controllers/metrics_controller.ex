defmodule ImpactTrackerWeb.MetricsController do
  use ImpactTrackerWeb, :controller
  require Logger

  def create(conn, _params) do
    Logger.info("Received metrics! Huzzah!")

    json(conn, %{status: :ok})
  end
end
