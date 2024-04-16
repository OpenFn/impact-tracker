defmodule ImpactTracker.Project do
  @moduledoc """
  Metrics captures for a single Lightning project

  """
  use Ecto.Schema

  import Ecto.Changeset

  alias ImpactTracker.Workflow

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "projects" do
    has_many :workflows, Workflow
    field :submission_id, Ecto.UUID
    field :cleartext_uuid, Ecto.UUID
    field :hashed_uuid, :string
    field :no_of_active_users, :integer
    field :no_of_users, :integer

    timestamps()
  end

  def v2_changeset(project, params) do
    cast_attrs = [
      :cleartext_uuid,
      :hashed_uuid,
      :no_of_active_users,
      :no_of_users
    ]

    required_attrs = [:hashed_uuid, :no_of_active_users, :no_of_users]

    project
    |> cast(params, cast_attrs)
    |> validate_required(required_attrs)
    |> validate_number(:no_of_active_users, greater_than_or_equal_to: 0)
    |> validate_number(:no_of_users, greater_than_or_equal_to: 0)
    |> validate_hashed_uuid()
    # Note - at the moment, there does not appear to be a cost-effective way
    # to validate that the `workflows` element is present
    |> cast_assoc(:workflows, with: &Workflow.v2_changeset/2)
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
