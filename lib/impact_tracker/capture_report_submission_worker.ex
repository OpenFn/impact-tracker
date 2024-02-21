defmodule ImpactTracker.CaptureReportSubmissionWorker do
  @moduledoc """
  Captures received metrics reports

  """
  use Oban.Worker, queue: :default

  import Ecto.Changeset

  alias ImpactTracker.Instance
  alias ImpactTracker.Repo
  alias ImpactTracker.Submission

  @impl Oban.Worker
  def perform(job) do
    %Oban.Job{args: %{"report" => report, "geolocation" => geolocation}} = job

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
    end

    :ok
  end
end
