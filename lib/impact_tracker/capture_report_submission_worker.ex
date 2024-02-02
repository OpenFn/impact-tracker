defmodule ImpactTracker.CaptureReportSubmissionWorker do
  @moduledoc """
  Captures received metrics reports

  """
  use Oban.Worker, queue: :default
  require Logger

  @impl Oban.Worker
  def perform(_args) do
    Logger.info("Received metrics! Huzzah!")

    :ok
  end
end
