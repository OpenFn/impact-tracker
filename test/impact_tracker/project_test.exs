defmodule ImpactTracker.ProjectTest do
  use ImpactTracker.DataCase

  alias Ecto.Changeset

  alias ImpactTracker.Project

  describe "v1_changeset/2" do
    test "returns a valid changeset" do
      data = build_project_data()

      %{"cleartext_uuid" => cleartext_uuid, "hashed_uuid" => hashed_uuid} = data

      changeset = %Project{} |> Project.v1_changeset(data)

      assert %Changeset{valid?: true, changes: changes} = changeset

      assert(
        %{
          cleartext_uuid: ^cleartext_uuid,
          hashed_uuid: ^hashed_uuid,
          no_of_users: 10
        } = changes
      )

      assert changes.workflows |> Enum.count() == 2
    end

    test "validates the presence of hashed_uuid" do
      changeset =
        %Project{}
        |> Project.v1_changeset(build_project_data_sans("hashed_uuid"))

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert(
        [
          hashed_uuid: {"can't be blank", [{:validation, :required}]}
        ] = errors
      )
    end

    test "is valid even if cleartext_uuid is absent" do
      changeset =
        %Project{}
        |> Project.v1_changeset(build_project_data_sans("cleartext_uuid"))

      assert %Changeset{valid?: true} = changeset
    end

    test "validates the presence of no_of_users" do
      changeset =
        %Project{}
        |> Project.v1_changeset(build_project_data_sans("no_of_users"))

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert(
        [
          no_of_users: {"can't be blank", [{:validation, :required}]}
        ] = errors
      )
    end

    test "validates that no_of_users is greater than or equal to 0" do
      changeset =
        %Project{} |> Project.v1_changeset(build_project_data("no_of_users", -1))

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert(
        [
          no_of_users: {
            "must be greater than or equal to %{number}",
            [
              {:validation, :number},
              {:kind, :greater_than_or_equal_to},
              {:number, 0}
            ]
          }
        ] = errors
      )

      changeset =
        %Project{} |> Project.v1_changeset(build_project_data("no_of_users", 0))

      assert %Changeset{valid?: true} = changeset

      changeset =
        %Project{} |> Project.v1_changeset(build_project_data("no_of_users", 1))

      assert %Changeset{valid?: true} = changeset
    end

    test "if cleartext_uuid is present, validates that the hashed_uuid matches" do
      changeset =
        %Project{}
        |> Project.v1_changeset(build_project_data("hashed_uuid", hash("foo")))

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert [hashed_uuid: {"is not a hash of cleartext uuid", []}] = errors
    end

    test "validates that hashed_uuid is the correct format if cleartext is absent" do
      data = build_project_data_with_hashed_uuid(correct_format_hash())

      changeset = %Project{} |> Project.v1_changeset(data)
      assert %Changeset{valid?: true} = changeset

      data =
        short_1_char_hash()
        |> build_project_data_with_hashed_uuid()

      %Project{}
      |> Project.v1_changeset(data)
      |> assert_incorrectly_formatted_hash

      data =
        extra_1_char_hash()
        |> build_project_data_with_hashed_uuid()

      %Project{}
      |> Project.v1_changeset(data)
      |> assert_incorrectly_formatted_hash

      data =
        non_alphanum_char_hash()
        |> build_project_data_with_hashed_uuid()

      %Project{}
      |> Project.v1_changeset(data)
      |> assert_incorrectly_formatted_hash
    end
  end

  defp build_project_data do
    uuid = generate_uuid()

    %{
      "cleartext_uuid" => uuid,
      "hashed_uuid" => hash(uuid),
      "no_of_users" => 10,
      "workflows" => build_workflow_data()
    }
  end

  defp build_workflow_data do
    uuid_1 = generate_uuid()
    uuid_2 = generate_uuid()

    [
      %{
        "cleartext_uuid" => uuid_1,
        "hashed_uuid" => hash(uuid_1),
        "no_of_jobs" => 1,
        "no_of_runs" => 2,
        "no_of_steps" => 3
      },
      %{
        "cleartext_uuid" => uuid_2,
        "hashed_uuid" => hash(uuid_2),
        "no_of_jobs" => 4,
        "no_of_runs" => 5,
        "no_of_steps" => 6
      }
    ]
  end

  defp build_project_data(key, value) do
    build_project_data() |> Map.merge(%{key => value})
  end

  defp build_project_data_sans(key) do
    build_project_data() |> Map.delete(key)
  end

  defp build_project_data_with_hashed_uuid(hashed_uuid) do
    build_project_data_sans("cleartext_uuid")
    |> Map.merge(%{"hashed_uuid" => hashed_uuid})
  end

  defp generate_uuid do
    Ecto.UUID.generate()
  end

  defp hash(uuid), do: Base.encode16(:crypto.hash(:sha256, uuid))

  defp correct_format_hash, do: String.duplicate("a1Db", 16)

  defp short_1_char_hash, do: String.duplicate("a1D", 21)

  defp extra_1_char_hash, do: String.duplicate("a1dB", 16) <> "x"

  defp non_alphanum_char_hash, do: String.duplicate("a1D", 21) <> "="

  defp assert_incorrectly_formatted_hash(changeset) do
    assert %Changeset{valid?: false, errors: errors} = changeset

    assert [
             hashed_uuid: {
               "does not appear to be valid SHA256",
               [validation: :format]
             }
           ] = errors
  end
end
