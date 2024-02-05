defmodule ImpactTracker.WorkflowTest do
  use ImpactTracker.DataCase

  alias Ecto.Changeset
  alias ImpactTracker.Workflow

  describe "changeset/2" do
    test "returns a valid changeset" do
      data = build_workflow_data()

      %{"cleartext_uuid" => cleartext_uuid, "hashed_uuid" => hashed_uuid} = data

      changeset = %Workflow{} |> Workflow.changeset(data)

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

    test "validates the presence of the hashed uuid" do
      changeset =
        %Workflow{}
        |> Workflow.changeset(build_workflow_data_sans("hashed_uuid"))

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert(
        [
          hashed_uuid: {"can't be blank", [{:validation, :required}]}
        ] = errors
      )
    end

    test "does not require the cleartext uuid to be present" do
      changeset =
        %Workflow{}
        |> Workflow.changeset(build_workflow_data_sans("cleartext_uuid"))

      assert %Changeset{valid?: true} = changeset
    end

    test "requires the no_of_jobs to be present" do
      changeset =
        %Workflow{}
        |> Workflow.changeset(build_workflow_data_sans("no_of_jobs"))

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert(
        [
          no_of_jobs: {"can't be blank", [{:validation, :required}]}
        ] = errors
      )
    end

    test "validates that no_of_jobs is greater than or equal to 0" do
      changeset =
        %Workflow{} |> Workflow.changeset(build_workflow_data("no_of_jobs", -1))

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
        %Workflow{} |> Workflow.changeset(build_workflow_data("no_of_jobs", 0))

      assert %Changeset{valid?: true} = changeset

      changeset =
        %Workflow{} |> Workflow.changeset(build_workflow_data("no_of_jobs", 1))

      assert %Changeset{valid?: true} = changeset
    end

    test "requires the no_of_runs to be present" do
      changeset =
        %Workflow{}
        |> Workflow.changeset(build_workflow_data_sans("no_of_runs"))

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert(
        [
          no_of_runs: {"can't be blank", [{:validation, :required}]}
        ] = errors
      )
    end

    test "validates that no_of_runs is greater than or equal to 0" do
      changeset =
        %Workflow{} |> Workflow.changeset(build_workflow_data("no_of_runs", -1))

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
        %Workflow{} |> Workflow.changeset(build_workflow_data("no_of_runs", 0))

      assert %Changeset{valid?: true} = changeset

      changeset =
        %Workflow{} |> Workflow.changeset(build_workflow_data("no_of_runs", 1))

      assert %Changeset{valid?: true} = changeset
    end

    test "requires the no_of_steps to be present" do
      changeset =
        %Workflow{}
        |> Workflow.changeset(build_workflow_data_sans("no_of_steps"))

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert(
        [
          no_of_steps: {"can't be blank", [{:validation, :required}]}
        ] = errors
      )
    end

    test "validates that no_of_steps is greater than or equal to 0" do
      changeset =
        %Workflow{} |> Workflow.changeset(build_workflow_data("no_of_steps", -1))

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
        %Workflow{} |> Workflow.changeset(build_workflow_data("no_of_steps", 0))

      assert %Changeset{valid?: true} = changeset

      changeset =
        %Workflow{} |> Workflow.changeset(build_workflow_data("no_of_steps", 1))

      assert %Changeset{valid?: true} = changeset
    end

    test "if cleartext_uuid is present, validates that the hashed_uuid matches" do
      changeset =
        %Workflow{}
        |> Workflow.changeset(build_workflow_data("hashed_uuid", hash("foo")))

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert [hashed_uuid: {"is not a hash of cleartext uuid", []}] = errors
    end

    test "validates that hashed_uuid is the correct format if cleartext is absent" do
      data = build_workflow_data_with_hashed_uuid(correct_format_hash())

      changeset = %Workflow{} |> Workflow.changeset(data)
      assert %Changeset{valid?: true} = changeset

      data =
        short_1_char_hash()
        |> build_workflow_data_with_hashed_uuid()

      %Workflow{}
      |> Workflow.changeset(data)
      |> assert_incorrectly_formatted_hash

      data =
        extra_1_char_hash()
        |> build_workflow_data_with_hashed_uuid()

      %Workflow{}
      |> Workflow.changeset(data)
      |> assert_incorrectly_formatted_hash

      data =
        non_alphanum_char_hash()
        |> build_workflow_data_with_hashed_uuid()

      %Workflow{}
      |> Workflow.changeset(data)
      |> assert_incorrectly_formatted_hash
    end
  end

  defp build_workflow_data do
    uuid = generate_uuid()

    %{
      "cleartext_uuid" => uuid,
      "hashed_uuid" => hash(uuid),
      "no_of_jobs" => 1,
      "no_of_runs" => 2,
      "no_of_steps" => 3
    }
  end

  defp build_workflow_data(key, value) do
    build_workflow_data() |> Map.merge(%{key => value})
  end

  defp build_workflow_data_sans(key) do
    build_workflow_data() |> Map.delete(key)
  end

  defp build_workflow_data_with_hashed_uuid(hashed_uuid) do
    build_workflow_data_sans("cleartext_uuid")
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
