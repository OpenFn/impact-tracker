defmodule ImpactTracker.ProjectTest do
  use ImpactTracker.DataCase

  alias Ecto.Changeset

  alias ImpactTracker.Project

  describe "v2_changeset/2" do
    setup do
      %{data: build_project_data()}
    end

    test "returns a valid changeset", %{data: data} do
      %{"cleartext_uuid" => cleartext_uuid, "hashed_uuid" => hashed_uuid} = data

      changeset = %Project{} |> Project.v2_changeset(data)

      assert %Changeset{valid?: true, changes: changes} = changeset

      assert(
        %{
          cleartext_uuid: ^cleartext_uuid,
          hashed_uuid: ^hashed_uuid,
          no_of_active_users: 7,
          no_of_users: 10
        } = changes
      )

      assert changes.workflows |> Enum.count() == 2
    end

    test "creates the associated workflows", %{data: data} do
      changeset = %Project{} |> Project.v2_changeset(data)

      %{changes: %{workflows: workflows}} = changeset

      assert [workflow | [_other_workflow]] = workflows

      %{changes: changes} = workflow

      assert changes |> Map.has_key?(:no_of_active_jobs)
    end

    test "validates the presence of hashed_uuid", %{data: data} do
      changeset =
        %Project{}
        |> Project.v2_changeset(data |> remove_data("hashed_uuid"))

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert(
        [
          hashed_uuid: {"can't be blank", [{:validation, :required}]}
        ] = errors
      )
    end

    test "is valid even if cleartext_uuid is absent", %{data: data} do
      changeset =
        %Project{}
        |> Project.v2_changeset(data |> remove_data("cleartext_uuid"))

      assert %Changeset{valid?: true} = changeset
    end

    test "validates the presence of no_of_users", %{data: data} do
      changeset =
        %Project{}
        |> Project.v2_changeset(data |> remove_data("no_of_users"))

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert(
        [
          no_of_users: {"can't be blank", [{:validation, :required}]}
        ] = errors
      )
    end

    test "validates that no_of_users >= 0", %{data: data} do
      changeset =
        %Project{}
        |> Project.v2_changeset(data |> modify_data("no_of_users", -1))

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
        %Project{}
        |> Project.v2_changeset(data |> modify_data("no_of_users", 0))

      assert %Changeset{valid?: true} = changeset

      changeset =
        %Project{}
        |> Project.v2_changeset(data |> modify_data("no_of_users", 1))

      assert %Changeset{valid?: true} = changeset
    end

    test "validates the presence of no_of_active_users", %{data: data} do
      changeset =
        %Project{}
        |> Project.v2_changeset(data |> remove_data("no_of_active_users"))

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert(
        [
          no_of_active_users: {"can't be blank", [{:validation, :required}]}
        ] = errors
      )
    end

    test "validates that no_of_active_users >= 0", %{data: data} do
      changeset =
        %Project{}
        |> Project.v2_changeset(data |> modify_data("no_of_active_users", -1))

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert(
        [
          no_of_active_users: {
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
        %Project{}
        |> Project.v2_changeset(data |> modify_data("no_of_active_users", 0))

      assert %Changeset{valid?: true} = changeset

      changeset =
        %Project{}
        |> Project.v2_changeset(data |> modify_data("no_of_active_users", 1))

      assert %Changeset{valid?: true} = changeset
    end

    test "validate hashed_uuid is a hash of cleartext", %{data: data} do
      changeset =
        %Project{}
        |> Project.v2_changeset(data |> modify_data("hashed_uuid", hash("foo")))

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert [hashed_uuid: {"is not a hash of cleartext uuid", []}] = errors
    end

    test "validate hashed_uuid format if cleartext absent", %{data: data} do
      with_correct_hash =
        data
        |> remove_clear_set_hashed(correct_format_hash())

      changeset =
        %Project{}
        |> Project.v2_changeset(with_correct_hash)

      assert %Changeset{valid?: true} = changeset

      truncated_hash =
        data
        |> remove_clear_set_hashed(short_1_char_hash())

      %Project{}
      |> Project.v2_changeset(truncated_hash)
      |> assert_incorrectly_formatted_hash

      extended_hash =
        data
        |> remove_clear_set_hashed(extra_1_char_hash())

      %Project{}
      |> Project.v2_changeset(extended_hash)
      |> assert_incorrectly_formatted_hash

      bad_chars_hash =
        data
        |> remove_clear_set_hashed(non_alphanum_char_hash())

      %Project{}
      |> Project.v2_changeset(bad_chars_hash)
      |> assert_incorrectly_formatted_hash
    end
  end

  defp build_project_data do
    uuid = generate_uuid()

    %{
      "cleartext_uuid" => uuid,
      "hashed_uuid" => hash(uuid),
      "no_of_active_users" => 7,
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
        "no_of_active_jobs" => 0,
        "no_of_jobs" => 1,
        "no_of_runs" => 2,
        "no_of_steps" => 3
      },
      %{
        "cleartext_uuid" => uuid_2,
        "hashed_uuid" => hash(uuid_2),
        "no_of_active_jobs" => 3,
        "no_of_jobs" => 4,
        "no_of_runs" => 5,
        "no_of_steps" => 6
      }
    ]
  end

  defp modify_data(data, key, value) do
    data |> Map.merge(%{key => value})
  end

  defp remove_data(data, key) do
    data |> Map.delete(key)
  end

  defp remove_clear_set_hashed(data, hashed_uuid) do
    data
    |> remove_data("cleartext_uuid")
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
