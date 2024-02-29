defmodule ImpactTracker.WorkflowTest do
  use ImpactTracker.DataCase

  alias Ecto.Changeset
  alias ImpactTracker.Workflow

  describe "v1_changeset/2" do
    setup do
      %{data: build_workflow_data("1")}
    end

    test "returns a valid changeset", %{data: data} do
      %{"cleartext_uuid" => cleartext_uuid, "hashed_uuid" => hashed_uuid} = data

      changeset = %Workflow{} |> Workflow.v1_changeset(data)

      assert %Changeset{valid?: true, changes: changes} = changeset

      assert(
        %{
          cleartext_uuid: ^cleartext_uuid,
          hashed_uuid: ^hashed_uuid,
          no_of_jobs: 1,
          no_of_runs: 2,
          no_of_steps: 3
        } = changes
      )
    end

    test "validates the presence of the hashed uuid", %{data: data} do
      changeset =
        %Workflow{}
        |> Workflow.v1_changeset(data |> remove_data("hashed_uuid"))

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert(
        [
          hashed_uuid: {"can't be blank", [{:validation, :required}]}
        ] = errors
      )
    end

    test "does not require the cleartext uuid to be present", %{data: data} do
      changeset =
        %Workflow{}
        |> Workflow.v1_changeset(data |> remove_data("cleartext_uuid"))

      assert %Changeset{valid?: true} = changeset
    end

    test "requires the no_of_jobs to be present", %{data: data} do
      changeset =
        %Workflow{}
        |> Workflow.v1_changeset(data |> remove_data("no_of_jobs"))

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert(
        [
          no_of_jobs: {"can't be blank", [{:validation, :required}]}
        ] = errors
      )
    end

    test "validates that no_of_jobs >= 0", %{data: data} do
      changeset =
        %Workflow{}
        |> Workflow.v1_changeset(data |> modify_data("no_of_jobs", -1))

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert(
        [
          no_of_jobs: {
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
        %Workflow{}
        |> Workflow.v1_changeset(data |> modify_data("no_of_jobs", 0))

      assert %Changeset{valid?: true} = changeset

      changeset =
        %Workflow{}
        |> Workflow.v1_changeset(data |> modify_data("no_of_jobs", 1))

      assert %Changeset{valid?: true} = changeset
    end

    test "requires the no_of_runs to be present", %{data: data} do
      changeset =
        %Workflow{}
        |> Workflow.v1_changeset(data |> remove_data("no_of_runs"))

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert(
        [
          no_of_runs: {"can't be blank", [{:validation, :required}]}
        ] = errors
      )
    end

    test "validates that no_of_runs is >= to 0", %{data: data} do
      changeset =
        %Workflow{}
        |> Workflow.v1_changeset(data |> modify_data("no_of_runs", -1))

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert(
        [
          no_of_runs: {
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
        %Workflow{}
        |> Workflow.v1_changeset(data |> modify_data("no_of_runs", 0))

      assert %Changeset{valid?: true} = changeset

      changeset =
        %Workflow{}
        |> Workflow.v1_changeset(data |> modify_data("no_of_runs", 1))

      assert %Changeset{valid?: true} = changeset
    end

    test "requires the no_of_steps to be present", %{data: data} do
      changeset =
        %Workflow{}
        |> Workflow.v1_changeset(data |> remove_data("no_of_steps"))

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert(
        [
          no_of_steps: {"can't be blank", [{:validation, :required}]}
        ] = errors
      )
    end

    test "validates that no_of_steps is >= 0", %{data: data} do
      changeset =
        %Workflow{}
        |> Workflow.v1_changeset(data |> modify_data("no_of_steps", -1))

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert(
        [
          no_of_steps: {
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
        %Workflow{}
        |> Workflow.v1_changeset(data |> modify_data("no_of_steps", 0))

      assert %Changeset{valid?: true} = changeset

      changeset =
        %Workflow{}
        |> Workflow.v1_changeset(data |> modify_data("no_of_steps", 1))

      assert %Changeset{valid?: true} = changeset
    end

    test "cleartext_uuid is present, validates hashed_uuid", %{data: data} do
      changeset =
        %Workflow{}
        |> Workflow.v1_changeset(data |> modify_data("hashed_uuid", hash("foo")))

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert [hashed_uuid: {"is not a hash of cleartext uuid", []}] = errors
    end

    test "cleartext_uuid is absent, validates hashed_uuid", %{data: data} do
      with_correct_hash =
        data
        |> remove_clear_set_hashed(correct_format_hash())

      changeset = %Workflow{} |> Workflow.v1_changeset(with_correct_hash)
      assert %Changeset{valid?: true} = changeset

      truncated_hash =
        data
        |> remove_clear_set_hashed(short_1_char_hash())

      %Workflow{}
      |> Workflow.v1_changeset(truncated_hash)
      |> assert_incorrectly_formatted_hash

      extended_hash =
        data
        |> remove_clear_set_hashed(extra_1_char_hash())

      %Workflow{}
      |> Workflow.v1_changeset(extended_hash)
      |> assert_incorrectly_formatted_hash

      bad_chars_hash =
        data
        |> remove_clear_set_hashed(non_alphanum_char_hash())

      %Workflow{}
      |> Workflow.v1_changeset(bad_chars_hash)
      |> assert_incorrectly_formatted_hash
    end
  end

  describe "v2_changeset/2" do
    setup do
      %{data: build_workflow_data("2")}
    end

    test "returns a valid changeset", %{data: data} do
      %{"cleartext_uuid" => cleartext_uuid, "hashed_uuid" => hashed_uuid} = data

      changeset = %Workflow{} |> Workflow.v2_changeset(data)

      assert %Changeset{valid?: true, changes: changes} = changeset

      assert(
        %{
          cleartext_uuid: ^cleartext_uuid,
          hashed_uuid: ^hashed_uuid,
          no_of_active_jobs: 9,
          no_of_jobs: 10,
          no_of_runs: 2,
          no_of_steps: 3
        } = changes
      )
    end

    test "validates the presence of the hashed uuid", %{data: data} do
      changeset =
        %Workflow{}
        |> Workflow.v2_changeset(data |> remove_data("hashed_uuid"))

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert(
        [
          hashed_uuid: {"can't be blank", [{:validation, :required}]}
        ] = errors
      )
    end

    test "does not require the cleartext uuid to be present", %{data: data} do
      changeset =
        %Workflow{}
        |> Workflow.v2_changeset(data |> remove_data("cleartext_uuid"))

      assert %Changeset{valid?: true} = changeset
    end

    test "requires the no_of_jobs to be present", %{data: data} do
      changeset =
        %Workflow{}
        |> Workflow.v2_changeset(data |> remove_data("no_of_jobs"))

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert(
        [
          no_of_jobs: {"can't be blank", [{:validation, :required}]}
        ] = errors
      )
    end

    test "validates that no_of_jobs >= 0", %{data: data} do
      changeset =
        %Workflow{}
        |> Workflow.v2_changeset(data |> modify_data("no_of_jobs", -1))

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert(
        [
          no_of_jobs: {
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
        %Workflow{}
        |> Workflow.v2_changeset(data |> modify_data("no_of_jobs", 0))

      assert %Changeset{valid?: true} = changeset

      changeset =
        %Workflow{}
        |> Workflow.v2_changeset(data |> modify_data("no_of_jobs", 1))

      assert %Changeset{valid?: true} = changeset
    end

    test "requires the no_of_active_jobs to be present", %{data: data} do
      changeset =
        %Workflow{}
        |> Workflow.v2_changeset(data |> remove_data("no_of_active_jobs"))

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert(
        [
          no_of_active_jobs: {"can't be blank", [{:validation, :required}]}
        ] = errors
      )
    end

    test "validates that no_of_active_jobs >= 0", %{data: data} do
      changeset =
        %Workflow{}
        |> Workflow.v2_changeset(data |> modify_data("no_of_active_jobs", -1))

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert(
        [
          no_of_active_jobs: {
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
        %Workflow{}
        |> Workflow.v2_changeset(data |> modify_data("no_of_active_jobs", 0))

      assert %Changeset{valid?: true} = changeset

      changeset =
        %Workflow{}
        |> Workflow.v2_changeset(data |> modify_data("no_of_active_jobs", 1))

      assert %Changeset{valid?: true} = changeset
    end

    test "requires the no_of_runs to be present", %{data: data} do
      changeset =
        %Workflow{}
        |> Workflow.v2_changeset(data |> remove_data("no_of_runs"))

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert(
        [
          no_of_runs: {"can't be blank", [{:validation, :required}]}
        ] = errors
      )
    end

    test "validates that no_of_runs is >= to 0", %{data: data} do
      changeset =
        %Workflow{}
        |> Workflow.v2_changeset(data |> modify_data("no_of_runs", -1))

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert(
        [
          no_of_runs: {
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
        %Workflow{}
        |> Workflow.v2_changeset(data |> modify_data("no_of_runs", 0))

      assert %Changeset{valid?: true} = changeset

      changeset =
        %Workflow{}
        |> Workflow.v2_changeset(data |> modify_data("no_of_runs", 1))

      assert %Changeset{valid?: true} = changeset
    end

    test "requires the no_of_steps to be present", %{data: data} do
      changeset =
        %Workflow{}
        |> Workflow.v2_changeset(data |> remove_data("no_of_steps"))

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert(
        [
          no_of_steps: {"can't be blank", [{:validation, :required}]}
        ] = errors
      )
    end

    test "validates that no_of_steps is >= 0", %{data: data} do
      changeset =
        %Workflow{}
        |> Workflow.v2_changeset(data |> modify_data("no_of_steps", -1))

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert(
        [
          no_of_steps: {
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
        %Workflow{}
        |> Workflow.v2_changeset(data |> modify_data("no_of_steps", 0))

      assert %Changeset{valid?: true} = changeset

      changeset =
        %Workflow{}
        |> Workflow.v2_changeset(data |> modify_data("no_of_steps", 1))

      assert %Changeset{valid?: true} = changeset
    end

    test "cleartext_uuid is present, validates hashed_uuid", %{data: data} do
      changeset =
        %Workflow{}
        |> Workflow.v2_changeset(data |> modify_data("hashed_uuid", hash("foo")))

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert [hashed_uuid: {"is not a hash of cleartext uuid", []}] = errors
    end

    test "cleartext_uuid is absent, validates hashed_uuid", %{data: data} do
      with_correct_hash =
        data
        |> remove_clear_set_hashed(correct_format_hash())

      changeset = %Workflow{} |> Workflow.v2_changeset(with_correct_hash)
      assert %Changeset{valid?: true} = changeset

      truncated_hash =
        data
        |> remove_clear_set_hashed(short_1_char_hash())

      %Workflow{}
      |> Workflow.v2_changeset(truncated_hash)
      |> assert_incorrectly_formatted_hash

      extended_hash =
        data
        |> remove_clear_set_hashed(extra_1_char_hash())

      %Workflow{}
      |> Workflow.v2_changeset(extended_hash)
      |> assert_incorrectly_formatted_hash

      bad_chars_hash =
        data
        |> remove_clear_set_hashed(non_alphanum_char_hash())

      %Workflow{}
      |> Workflow.v2_changeset(bad_chars_hash)
      |> assert_incorrectly_formatted_hash
    end
  end

  defp build_workflow_data(_version = "1") do
    uuid = generate_uuid()

    %{
      "cleartext_uuid" => uuid,
      "hashed_uuid" => hash(uuid),
      "no_of_jobs" => 1,
      "no_of_runs" => 2,
      "no_of_steps" => 3
    }
  end

  defp build_workflow_data(_version = "2") do
    uuid = generate_uuid()

    %{
      "cleartext_uuid" => uuid,
      "hashed_uuid" => hash(uuid),
      "no_of_active_jobs" => 9,
      "no_of_jobs" => 10,
      "no_of_runs" => 2,
      "no_of_steps" => 3
    }
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
