defmodule ImpactTracker.CaptureReportSubmissionWorkerTest do
  use ImpactTracker.DataCase

  alias ImpactTracker.CaptureReportSubmissionWorker, as: Worker
  alias ImpactTracker.Instance
  alias ImpactTracker.Submission

  describe "capturing submitted metrics" do
    test "creates an instance entry if one does not exist" do
      _existing_instance = insert(:instance)

      data = build_submission_data()

      %{report: %{instance: %{hashed_uuid: hashed_uuid}}} = data

      assert :ok = perform_job(Worker, data)

      instance = Instance |> Repo.get_by(hashed_uuid: hashed_uuid)

      assert instance

      assert(is_nil(instance.cleartext_uuid))
    end

    test "does not create an instance entry if the instance data is invalid" do
      data = build_submission_data(hash: broken_hash())

      assert :ok = perform_job(Worker, data)

      assert Instance |> Repo.one() == nil
    end

    test "does not create an instance entry if one already exists" do
      data = build_submission_data()

      %{report: %{instance: %{hashed_uuid: hashed_uuid}}} = data

      _existing_instance = insert(:instance, hashed_uuid: hashed_uuid)

      assert :ok = perform_job(Worker, data)

      assert Instance |> Repo.all() |> Enum.count() == 1
    end

    test "creates a new submission and associated instance" do
      data = build_submission_data()

      assert :ok = perform_job(Worker, data)

      assert %Submission{
               country: "US",
               operating_system: "linux",
               region: "North Dakota"
             } = Submission |> Repo.one()
    end

    test "creates a new submission for an existing instance" do
      data = build_submission_data()

      %{report: %{instance: %{hashed_uuid: hashed_uuid}}} = data

      existing_instance = insert(:instance, hashed_uuid: hashed_uuid)

      _existing_submission =
        insert(:submission,
          instance_id: existing_instance.id,
          operating_system: "winnt"
        )

      assert :ok = perform_job(Worker, data)

      assert Submission |> Repo.all() |> Enum.count() == 2

      assert(
        Submission
        |> Repo.get_by(
          country: "US",
          operating_system: "linux",
          region: "North Dakota",
          instance_id: existing_instance.id
        ) != nil
      )
    end

    test "does not create new submission and instance when data is invalid" do
      data = build_submission_data(workflows: build_broken_workflows_data())

      assert :ok = perform_job(Worker, data)

      assert Submission |> Repo.one() == nil
    end

    test "does not add submission to existing instance when data is invalid" do
      data = build_submission_data(workflows: build_broken_workflows_data())

      %{report: %{instance: %{hashed_uuid: hashed_uuid}}} = data

      existing_instance = insert(:instance, hashed_uuid: hashed_uuid)

      _existing_submission =
        insert(:submission,
          instance_id: existing_instance.id,
          operating_system: "winnt"
        )

      assert :ok = perform_job(Worker, data)

      assert(
        Submission
        |> Repo.get_by(
          country: "US",
          operating_system: "linux",
          region: "North Dakota",
          instance_id: existing_instance.id
        ) == nil
      )
    end

    defp generate_uuid do
      Ecto.UUID.generate()
    end

    defp build_submission_data(options \\ []) do
      uuid = generate_uuid()
      hash = options |> Keyword.get(:hash, build_hash(uuid))
      workflows = options |> Keyword.get(:workflows, build_workflows_data())

      %{
        report: %{
          generated_at: "2024-02-06T12:50:37.245897Z",
          instance: build_instance_data(uuid, hash),
          projects: build_projects_data(workflows),
          report_date: ~D[2024-02-05],
          version: "2"
        },
        geolocation: %{
          country: "US",
          region: "North Dakota"
        }
      }
    end

    defp build_instance_data(uuid, hash) do
      build_identity_data(uuid, hash)
      |> Map.merge(%{
        operating_system: "linux",
        no_of_active_users: 8,
        no_of_users: 10,
        version: "2.0.0rc1"
      })
    end

    defp build_identity_data(_uuid, hash) do
      %{
        cleartext_uuid: nil,
        hashed_uuid: hash
      }
    end

    defp build_projects_data(workflows) do
      [
        %{
          no_of_active_users: 3,
          no_of_users: 10,
          workflows: workflows
        }
        |> Map.merge(build_identity_data(nil, build_hash("bar")))
      ]
    end

    defp build_workflows_data do
      [
        %{
          no_of_active_jobs: 3,
          no_of_jobs: 4,
          no_of_runs: 5,
          no_of_steps: 6
        }
        |> Map.merge(build_identity_data(nil, build_hash("foo")))
      ]
    end

    defp build_broken_workflows_data do
      [
        %{
          no_of_active_jobs: -3,
          no_of_jobs: 4,
          no_of_runs: 5,
          no_of_steps: 6
        }
        |> Map.merge(build_identity_data(nil, build_hash("foo")))
      ]
    end

    defp build_hash(uuid), do: Base.encode16(:crypto.hash(:sha256, uuid))

    defp broken_hash, do: "123"
  end
end
