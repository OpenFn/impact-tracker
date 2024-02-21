defmodule ImpactTrackerWeb.Controllers.MetricsControllerTest do
  use ImpactTrackerWeb.ConnCase

  import Mock

  # Configuration of IP responses for GeoIP can be found in runtime.ex

  describe "create" do
    test "passes JSON to job for processing", %{conn: conn} do
      report = %{"foo" => "bar"}

      conn =
        conn
        |> Plug.Conn.put_req_header("content-type", "application/json")
        |> Plug.Conn.put_req_header("x-forwarded-for", "20.20.20.20, 10.0.0.1")
        |> post(~p"/api/metrics", Jason.encode!(report))

      assert conn.status == 202

      assert_enqueued(
        worker: ImpactTracker.CaptureReportSubmissionWorker,
        args: %{
          "report" => report,
          "geolocation" => %{
            "country" => "ZA",
            "region" => "Western Cape"
          }
        }
      )
    end

    test "sets country if only country returned", %{conn: conn} do
      report = %{"foo" => "bar"}

      conn
      |> Plug.Conn.put_req_header("content-type", "application/json")
      |> Plug.Conn.put_req_header("x-forwarded-for", "21.21.21.21, 10.0.0.1")
      |> post(~p"/api/metrics", Jason.encode!(report))

      assert_enqueued(
        worker: ImpactTracker.CaptureReportSubmissionWorker,
        args: %{
          "report" => report,
          "geolocation" => %{
            "country" => "CH",
            "region" => nil
          }
        }
      )
    end

    test "sets country & region to nil if not returned", %{conn: conn} do
      report = %{"foo" => "bar"}

      conn
      |> Plug.Conn.put_req_header("content-type", "application/json")
      |> Plug.Conn.put_req_header("x-forwarded-for", "22.22.22.22, 10.0.0.1")
      |> post(~p"/api/metrics", Jason.encode!(report))

      assert_enqueued(
        worker: ImpactTracker.CaptureReportSubmissionWorker,
        args: %{
          "report" => report,
          "geolocation" => %{
            "country" => nil,
            "region" => nil
          }
        }
      )
    end

    test "sets country & region to nil if lookup error", %{conn: conn} do
      report = %{"foo" => "bar"}

      with_mock GeoIP,
        lookup: fn _conn -> {:error, %GeoIP.Error{reason: "x!", id: nil}} end do
        conn
        |> Plug.Conn.put_req_header("content-type", "application/json")
        |> Plug.Conn.put_req_header("x-forwarded-for", "20.20.20.20, 10.0.0.1")
        |> post(~p"/api/metrics", Jason.encode!(report))

        assert_enqueued(
          worker: ImpactTracker.CaptureReportSubmissionWorker,
          args: %{
            "report" => report,
            "geolocation" => %{
              "country" => nil,
              "region" => nil
            }
          }
        )
      end
    end
  end
end
