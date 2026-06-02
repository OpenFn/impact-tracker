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
    field :no_of_monthly_active_users, :integer
    field :no_of_users, :integer

    timestamps()
  end

  def v2_changeset(project, params) do
    changeset(project, params, include_monthly_active_users: false)
  end

  # Version 3 adds a 30-day `no_of_monthly_active_users` alongside the existing
  # 90-day `no_of_active_users`.
  def v3_changeset(project, params) do
    changeset(project, params, include_monthly_active_users: true)
  end

  defp changeset(project, params, include_monthly_active_users: include_mau) do
    mau_attrs = if include_mau, do: [:no_of_monthly_active_users], else: []

    cast_attrs =
      [
        :cleartext_uuid,
        :hashed_uuid,
        :no_of_active_users,
        :no_of_users
      ] ++ mau_attrs

    required_attrs =
      [:hashed_uuid, :no_of_active_users, :no_of_users] ++ mau_attrs

    project
    |> cast(params, cast_attrs)
    |> validate_required(required_attrs)
    |> validate_number(:no_of_active_users, greater_than_or_equal_to: 0)
    |> validate_number(:no_of_users, greater_than_or_equal_to: 0)
    |> maybe_validate_monthly_active_users(include_mau)
    |> validate_hashed_uuid()
    # Note - at the moment, there does not appear to be a cost-effective way
    # to validate that the `workflows` element is present
    |> cast_assoc(:workflows, with: &Workflow.v2_changeset/2)
  end

  defp maybe_validate_monthly_active_users(changeset, true) do
    validate_number(changeset, :no_of_monthly_active_users,
      greater_than_or_equal_to: 0
    )
  end

  defp maybe_validate_monthly_active_users(changeset, false), do: changeset

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
