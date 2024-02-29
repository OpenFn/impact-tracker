defmodule ImpactTracker.SubmissionTest do
  use ImpactTracker.DataCase

  alias Ecto.Changeset

  alias ImpactTracker.Submission

  describe ".new/3 version 1" do
    test "generates a valid changeset" do
      changeset =
        %Submission{}
        |> Submission.new(build_submission_data(), build_geolocation_data())

      {:ok, generated_at, 0} =
        DateTime.from_iso8601("2024-02-06T12:50:37.245897Z")

      assert %Changeset{valid?: true, changes: changes} = changeset

      assert %{
               country: "US",
               generated_at: ^generated_at,
               lightning_version: "2.0.0rc1",
               no_of_users: 10,
               operating_system: "linux",
               region: "Iowa",
               version: "1"
             } = changes

      assert changes.projects |> Enum.count() == 2
    end

    test "generates an invalid changeset if the `instance` element is absent" do
      changeset =
        %Submission{}
        |> Submission.new(
          build_submission_data_sans("instance"),
          build_geolocation_data()
        )

      assert %Changeset{valid?: false} = changeset
    end

    test "validates the presence of generated_at" do
      changeset =
        %Submission{}
        |> Submission.new(
          build_submission_data_sans("generated_at"),
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

    test "validates the presence of lightning_version" do
      changeset =
        %Submission{}
        |> Submission.new(
          build_submission_data_sans("instance", "version"),
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

    test "validates the presence of no_of_users" do
      changeset =
        %Submission{}
        |> Submission.new(
          build_submission_data_sans("instance", "no_of_users"),
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

    test "validates that no_of_users is greater than or equal to zero" do
      changeset =
        %Submission{}
        |> Submission.new(
          build_submission_data("instance", "no_of_users", -1),
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
          build_submission_data("instance", "no_of_users", 0),
          build_geolocation_data()
        )

      assert %Changeset{valid?: true} = changeset

      changeset =
        %Submission{}
        |> Submission.new(
          build_submission_data("instance", "no_of_users", 1),
          build_geolocation_data()
        )

      assert %Changeset{valid?: true} = changeset
    end

    test "validates the presence of operating_system" do
      changeset =
        %Submission{}
        |> Submission.new(
          build_submission_data_sans("instance", "operating_system"),
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

    test "validates the presence of version" do
      changeset =
        %Submission{}
        |> Submission.new(
          build_submission_data_sans("version"),
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

    test "validates that the submission version is supported" do
      changeset =
        %Submission{}
        |> Submission.new(
          build_submission_data("version", "2"),
          build_geolocation_data()
        )

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert [
               version:
                 {"is invalid", [{:validation, :inclusion}, {:enum, ["1"]}]}
             ] = errors
    end

    test "validates that the projects collection is present" do
      changeset =
        %Submission{}
        |> Submission.new(
          build_submission_data_sans("projects"),
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

    test "overwrites any geolocation data that may be in the report data" do
      report_data =
        build_submission_data()
        |> Map.merge(%{"country" => "ZA", "region" => "Gauteng"})

      changeset =
        %Submission{}
        |> Submission.new(report_data, build_geolocation_data())

      assert %Changeset{valid?: true, changes: changes} = changeset

      assert %{country: "US", region: "Iowa"} = changes
    end

    test "it does not require the geolocation data to be populated" do
      changeset =
        %Submission{}
        |> Submission.new(build_submission_data(), build_nil_geolocation_data())

      assert %Changeset{valid?: true} = changeset
    end
  end

  defp build_submission_data do
    %{
      "generated_at" => "2024-02-06T12:50:37.245897Z",
      "instance" => %{
        "operating_system" => "linux",
        "no_of_users" => 10,
        "version" => "2.0.0rc1"
      },
      "projects" => build_project_data(),
      "version" => "1"
    }
  end

  defp build_submission_data(key, value) do
    build_submission_data() |> Map.merge(%{key => value})
  end

  defp build_submission_data(parent_key, key, value) do
    data = build_submission_data()

    new_data = data[parent_key] |> Map.merge(%{key => value})

    data |> Map.merge(%{parent_key => new_data})
  end

  defp build_submission_data_sans(key) do
    build_submission_data() |> Map.delete(key)
  end

  defp build_submission_data_sans(parent_key, key, existing_data \\ nil) do
    data = existing_data || build_submission_data()

    key_removed =
      data[parent_key]
      |> Map.delete(key)

    data |> Map.merge(%{parent_key => key_removed})
  end

  defp build_geolocation_data, do: %{"country" => "US", "region" => "Iowa"}

  defp build_nil_geolocation_data, do: %{"country" => nil, "region" => nil}

  defp build_project_data do
    [
      %{
        "cleartext_uuid" => nil,
        "hashed_uuid" => hash("foo"),
        "no_of_users" => 10,
        "workflows" => []
      },
      %{
        "cleartext_uuid" => nil,
        "hashed_uuid" => hash("bar"),
        "no_of_users" => 30,
        "workflows" => []
      }
    ]
  end

  defp hash(uuid), do: Base.encode16(:crypto.hash(:sha256, uuid))
end
