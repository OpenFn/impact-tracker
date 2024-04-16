defmodule ImpactTracker.SubmissionTest do
  use ImpactTracker.DataCase

  alias Ecto.Changeset

  alias ImpactTracker.Submission

  describe ".new/3 version 2" do
    setup do
      %{data: build_submission_data()}
    end

    test "generates a valid changeset for the submission", %{data: data} do
      changeset =
        %Submission{}
        |> Submission.new(data, build_geolocation_data())

      {:ok, generated_at, 0} =
        DateTime.from_iso8601("2024-02-06T12:50:37.245897Z")

      report_date = Date.from_iso8601!("2024-02-05")

      assert %Changeset{valid?: true, changes: changes} = changeset

      assert(
        %{
          country: "US",
          generated_at: ^generated_at,
          lightning_version: "2.0.0rc1",
          no_of_active_users: 7,
          no_of_users: 10,
          operating_system: "linux",
          region: "Iowa",
          report_date: ^report_date,
          version: "2"
        } = changes
      )

      assert changes.projects |> Enum.count() == 2
    end

    test "generates valid changesets for the projects", %{data: data} do
      changeset =
        %Submission{}
        |> Submission.new(data, build_geolocation_data())

      %{changes: %{projects: projects}} = changeset

      assert(
        [
          %{changes: %{no_of_active_users: 3}},
          %{changes: %{no_of_active_users: 4}}
        ] = projects
      )
    end

    test "vaidates presence of `instance`", %{data: data} do
      changeset =
        %Submission{}
        |> Submission.new(
          data |> remove_data("instance"),
          build_geolocation_data()
        )

      assert %Changeset{valid?: false} = changeset
    end

    test "validates presence of `generated_at`", %{data: data} do
      changeset =
        %Submission{}
        |> Submission.new(
          data |> remove_data("generated_at"),
          build_geolocation_data()
        )

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert [
               generated_at: {
                 "can't be blank",
                 [{:validation, :required}]
               }
             ] = errors
    end

    test "validates presence of `lightning_version`", %{data: data} do
      changeset =
        %Submission{}
        |> Submission.new(
          data |> remove_data("instance", "version"),
          build_geolocation_data()
        )

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert [
               lightning_version: {
                 "can't be blank",
                 [{:validation, :required}]
               }
             ] = errors
    end

    test "validates presence of `no_of_active_users`", %{data: data} do
      changeset =
        %Submission{}
        |> Submission.new(
          data |> remove_data("instance", "no_of_active_users"),
          build_geolocation_data()
        )

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert [
               no_of_active_users: {
                 "can't be blank",
                 [{:validation, :required}]
               }
             ] = errors
    end

    test "validates that no_of_active_users is >= 0", %{data: data} do
      changeset =
        %Submission{}
        |> Submission.new(
          data |> modify_submission_data("instance", "no_of_active_users", -1),
          build_geolocation_data()
        )

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert [
               no_of_active_users: {
                 "must be greater than or equal to %{number}",
                 [
                   {:validation, :number},
                   {:kind, :greater_than_or_equal_to},
                   {:number, 0}
                 ]
               }
             ] = errors

      changeset =
        %Submission{}
        |> Submission.new(
          data |> modify_submission_data("instance", "no_of_active_users", 0),
          build_geolocation_data()
        )

      assert %Changeset{valid?: true} = changeset

      changeset =
        %Submission{}
        |> Submission.new(
          data |> modify_submission_data("instance", "no_of_active_users", 1),
          build_geolocation_data()
        )

      assert %Changeset{valid?: true} = changeset
    end

    test "validates presence of `no_of_users`", %{data: data} do
      changeset =
        %Submission{}
        |> Submission.new(
          data |> remove_data("instance", "no_of_users"),
          build_geolocation_data()
        )

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert [
               no_of_users: {
                 "can't be blank",
                 [{:validation, :required}]
               }
             ] = errors
    end

    test "validates that no_of_users is >= 0", %{data: data} do
      changeset =
        %Submission{}
        |> Submission.new(
          data |> modify_submission_data("instance", "no_of_users", -1),
          build_geolocation_data()
        )

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert [
               no_of_users: {
                 "must be greater than or equal to %{number}",
                 [
                   {:validation, :number},
                   {:kind, :greater_than_or_equal_to},
                   {:number, 0}
                 ]
               }
             ] = errors

      changeset =
        %Submission{}
        |> Submission.new(
          data |> modify_submission_data("instance", "no_of_users", 0),
          build_geolocation_data()
        )

      assert %Changeset{valid?: true} = changeset

      changeset =
        %Submission{}
        |> Submission.new(
          data |> modify_submission_data("instance", "no_of_users", 1),
          build_geolocation_data()
        )

      assert %Changeset{valid?: true} = changeset
    end

    test "validates presence of operating_system", %{data: data} do
      changeset =
        %Submission{}
        |> Submission.new(
          data |> remove_data("instance", "operating_system"),
          build_geolocation_data()
        )

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert [
               operating_system: {
                 "can't be blank",
                 [{:validation, :required}]
               }
             ] = errors
    end

    test "validates presence of `report_date`", %{data: data} do
      changeset =
        %Submission{}
        |> Submission.new(
          data |> remove_data("report_date"),
          build_geolocation_data()
        )

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert [
               report_date: {
                 "can't be blank",
                 [{:validation, :required}]
               }
             ] = errors
    end

    test "validates the presence of version", %{data: data} do
      changeset =
        %Submission{}
        |> Submission.new(
          data |> remove_data("version"),
          build_geolocation_data()
        )

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert [
               version: {
                 "can't be blank",
                 [{:validation, :required}]
               }
             ] = errors
    end

    test "validates the submission version is supported", %{data: data} do
      changeset =
        %Submission{}
        |> Submission.new(
          data |> modify_submission_data("version", "1001"),
          build_geolocation_data()
        )

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert [
               version:
                 {"is invalid", [{:validation, :inclusion}, {:enum, ["1", "2"]}]}
             ] = errors
    end

    test "validates presence of projects", %{data: data} do
      changeset =
        %Submission{}
        |> Submission.new(
          data |> remove_data("projects"),
          build_geolocation_data()
        )

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert [
               projects: {
                 "is invalid",
                 [{:validation, :assoc}, {:type, {:array, :map}}]
               }
             ] = errors
    end

    test "overwrites geolocation data in report data", %{data: data} do
      report_data =
        data
        |> Map.merge(%{"country" => "ZA", "region" => "Gauteng"})

      changeset =
        %Submission{}
        |> Submission.new(report_data, build_geolocation_data())

      assert %Changeset{valid?: true, changes: changes} = changeset

      assert %{country: "US", region: "Iowa"} = changes
    end

    test "it does not require geolocation data", %{data: data} do
      changeset =
        %Submission{}
        |> Submission.new(data, build_nil_geolocation_data())

      assert %Changeset{valid?: true} = changeset
    end

    test "creates invalid changeset - report date exists for instance", %{
      data: data
    } do
      instance =
        insert(
          :instance,
          submissions: [build(:submission, report_date: ~D[2024-02-05])]
        )

      result =
        instance
        |> Ecto.build_assoc(:submissions)
        |> Submission.new(data, build_geolocation_data())
        |> Repo.insert()

      assert {:error, changeset} = result

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert [
               instance_id: {
                 "instance already has a submission for this date",
                 [
                   constraint: :unique,
                   constraint_name: "submissions_instance_id_report_date_index"
                 ]
               }
             ] = errors
    end
  end

  defp build_submission_data do
    %{
      "generated_at" => "2024-02-06T12:50:37.245897Z",
      "instance" => %{
        "operating_system" => "linux",
        "no_of_active_users" => 7,
        "no_of_users" => 10,
        "version" => "2.0.0rc1"
      },
      "projects" => build_project_data(),
      "report_date" => "2024-02-05",
      "version" => "2"
    }
  end

  defp modify_submission_data(submission, key, value) do
    submission |> Map.merge(%{key => value})
  end

  defp modify_submission_data(submission, parent_key, key, value) do
    new_data = submission[parent_key] |> Map.merge(%{key => value})

    submission |> Map.merge(%{parent_key => new_data})
  end

  defp remove_data(submission, key) do
    submission |> Map.delete(key)
  end

  defp remove_data(submission, parent_key, key) do
    key_removed = submission[parent_key] |> Map.delete(key)

    submission |> Map.merge(%{parent_key => key_removed})
  end

  defp build_geolocation_data, do: %{"country" => "US", "region" => "Iowa"}

  defp build_nil_geolocation_data, do: %{"country" => nil, "region" => nil}

  defp build_project_data do
    [
      %{
        "cleartext_uuid" => nil,
        "hashed_uuid" => hash("foo"),
        "no_of_active_users" => 3,
        "no_of_users" => 10,
        "workflows" => []
      },
      %{
        "cleartext_uuid" => nil,
        "hashed_uuid" => hash("bar"),
        "no_of_active_users" => 4,
        "no_of_users" => 30,
        "workflows" => []
      }
    ]
  end

  defp hash(uuid), do: Base.encode16(:crypto.hash(:sha256, uuid))
end
