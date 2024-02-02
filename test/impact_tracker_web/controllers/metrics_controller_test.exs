defmodule ImpactTrackerWeb.Controllers.MetricsControllerTest do
  use ImpactTrackerWeb.ConnCase

  describe "create" do
    test "passes JSON to job for processing", %{conn: conn} do
      report = %{"foo" => "bar"}

      conn =
        conn
        |> Plug.Conn.put_req_header("content-type", "application/json")
        |> post(~p"/api/metrics", Jason.encode!(report))

      assert conn.status == 202

      assert_enqueued(
        worker: ImpactTracker.CaptureReportSubmissionWorker,
        args: report
      )
    end
  end
end
