defmodule ImpactTrackerWeb.MetricsController do
  use ImpactTrackerWeb, :controller

  require Logger

  def create(conn, params) do
    {country, region} = geolocation_data(conn)
    Logger.info("Country #{country}")
    Logger.info("Region #{region}")

    %{report: params}
    |> Map.merge(%{geolocation: %{country: country, region: region}})
    |> ImpactTracker.CaptureReportSubmissionWorker.new()
    |> Oban.insert()

    conn
    |> put_status(:accepted)
    |> json(%{status: :ok})
  end

  defp geolocation_data(conn) do
    case GeoIP.lookup(conn) do
      {:ok, %{region: region, country: country}} -> {country, region}
      {:ok, %{country: country}} -> {country, nil}
      _ -> {nil, nil}
    end
  end
end
