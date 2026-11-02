defmodule ImpactTracker.CaptureReportSubmissionWorker do
  @moduledoc """
  Captures received metrics reports

  """
  use Oban.Worker, queue: :default

  import Ecto.Changeset

  require Logger

  alias ImpactTracker.Instance
  alias ImpactTracker.Repo
  alias ImpactTracker.Submission

  @impl Oban.Worker
  def perform(job) do
    %Oban.Job{args: %{"report" => report, "geolocation" => geolocation}} = job

    case capture(report, geolocation) do
      {:ok, _} ->
        :ok

      # An invalid report won't become valid on retry, so the job still
      # succeeds, but the drop is logged so it isn't silent.
      {:error, changeset} ->
        Logger.warning(
          "Dropped report (version #{inspect(report["version"])}): " <>
            inspect(error_messages(changeset))
        )

        :ok
    end
  end

  defp capture(report, geolocation) do
    instance_changeset = Instance.new(report)

    if instance_changeset.valid? do
      %{changes: %{hashed_uuid: hashed_uuid}} = instance_changeset

      if instance = Instance |> Repo.get_by(hashed_uuid: hashed_uuid) do
        instance
        |> Ecto.build_assoc(:submissions)
        |> Submission.new(report, geolocation)
        |> Repo.insert()
      else
        submission_changeset = Submission.new(%Submission{}, report, geolocation)

        instance_changeset
        |> put_assoc(:submissions, [submission_changeset])
        |> Repo.insert()
      end
    else
      {:error, instance_changeset}
    end
  end

  # Field names and messages only, never the submitted values.
  defp error_messages(changeset) do
    traverse_errors(changeset, fn {message, _opts} -> message end)
  end
end
