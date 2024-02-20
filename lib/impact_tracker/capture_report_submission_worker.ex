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
    %Oban.Job{args: submission} = job

    instance_changeset = Instance.new(submission)

    if instance_changeset.valid? do
      %{changes: %{hashed_uuid: hashed_uuid}} = instance_changeset

      if instance = Instance |> Repo.get_by(hashed_uuid: hashed_uuid) do
        instance
        |> Ecto.build_assoc(:submissions)
        |> Submission.new(submission)
        |> Repo.insert()
      else
        submission_changeset = Submission.new(%Submission{}, submission)

        instance_changeset
        |> put_assoc(:submissions, [submission_changeset])
        |> Repo.insert()
      end
    end

    :ok
  end
end
