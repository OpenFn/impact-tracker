defmodule ImpactTrackerWeb.MetricsController do
  use ImpactTrackerWeb, :controller

  def create(conn, params) do
    params
    |> ImpactTracker.CaptureReportSubmissionWorker.new()
    |> Oban.insert()

    conn
    |> put_status(:accepted)
    |> json(%{status: :ok})
  end
end
