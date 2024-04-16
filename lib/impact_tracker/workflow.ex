defmodule ImpactTracker.Workflow do
  @moduledoc """
  Metrics captured for a single Lightning workflow

  """
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "workflows" do
    field :project_id, Ecto.UUID
    field :cleartext_uuid, Ecto.UUID
    field :hashed_uuid, :string
    field :no_of_active_jobs, :integer
    field :no_of_jobs, :integer
    field :no_of_runs, :integer
    field :no_of_steps, :integer

    timestamps()
  end

  def v2_changeset(workflow, params) do
    cast_attrs = [
      :cleartext_uuid,
      :hashed_uuid,
      :no_of_active_jobs,
      :no_of_jobs,
      :no_of_runs,
      :no_of_steps
    ]

    required_attrs = [
      :hashed_uuid,
      :no_of_active_jobs,
      :no_of_jobs,
      :no_of_runs,
      :no_of_steps
    ]

    workflow
    |> cast(params, cast_attrs)
    |> validate_required(required_attrs)
    |> validate_number(:no_of_active_jobs, greater_than_or_equal_to: 0)
    |> validate_number(:no_of_jobs, greater_than_or_equal_to: 0)
    |> validate_number(:no_of_runs, greater_than_or_equal_to: 0)
    |> validate_number(:no_of_steps, greater_than_or_equal_to: 0)
    |> validate_hashed_uuid()
  end

  defp validate_hashed_uuid(changeset = %{changes: %{cleartext_uuid: cleartext}}) do
    validate_change(changeset, :hashed_uuid, fn _, hash ->
      if hash == Base.encode16(:crypto.hash(:sha256, cleartext)) do
        []
      else
        [hashed_uuid: "is not a hash of cleartext uuid"]
      end
    end)
  end

  defp validate_hashed_uuid(changeset) do
    changeset
    |> validate_format(
      :hashed_uuid,
      ~r/\A[a-z0-9]{64}\z/i,
      message: "does not appear to be valid SHA256"
    )
  end
end
