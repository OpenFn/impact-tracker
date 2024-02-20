defmodule ImpactTrackerWeb.MetricsController do
  use ImpactTrackerWeb, :controller

  require Logger

  def create(conn, params) do
    Logger.info("Ip Connected #{inspect conn.remote_ip}")
    Logger.info("XFF #{inspect get_req_header(conn, "x-forwarded-for")}")
    Logger.info("FF #{inspect get_req_header(conn, "forwarded-for")}")

    params
    |> ImpactTracker.CaptureReportSubmissionWorker.new()
    |> Oban.insert()

    conn
    |> put_status(:accepted)
    |> json(%{status: :ok})
  end
end
