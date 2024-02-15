defmodule ImpactTracker.Submission do
  @moduledoc """
  Every time an instance submits metrics, a Submission is created.

  """
  use Ecto.Schema

  import Ecto.Changeset

  alias ImpactTracker.Project

  # When adding new versions, update this.
  @supported_versions ["1"]

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "submissions" do
    has_many :projects, Project

    field :generated_at, :utc_datetime_usec
    field :instance_id, Ecto.UUID
    field :lightning_version, :string
    field :no_of_users, :integer
    field :operating_system, :string
    field :operating_system_detail, :string
    field :version, :string

    timestamps()
  end

  def new(struct, attrs) do
    submission_attrs = attrs |> extract_submission_attrs()

    cast_attrs = [
      :generated_at,
      :lightning_version,
      :no_of_users,
      :operating_system,
      :operating_system_detail,
      :version
    ]

    required_attrs = [
      :generated_at,
      :lightning_version,
      :no_of_users,
      :operating_system,
      :version
    ]

    struct
    |> cast(submission_attrs, cast_attrs)
    |> validate_required(required_attrs)
    |> validate_number(:no_of_users, greater_than_or_equal_to: 0)
    |> validate_inclusion(:version, @supported_versions)
    |> validate_operating_system()
    |> cast_assoc(:projects)
  end

  defp extract_submission_attrs(attrs) do
    %{
      generated_at: attrs |> extract_attr("generated_at"),
      lightning_version: attrs |> extract_attr("instance", "version"),
      no_of_users: attrs |> extract_attr("instance", "no_of_users"),
      operating_system: attrs |> extract_attr("instance", "operating_system"),
      operating_system_detail:
        attrs |> extract_attr("instance", "operating_system_detail"),
      projects: attrs |> extract_attr("projects"),
      version: attrs |> extract_attr("version")
    }
  end

  defp extract_attr(attrs, key) do
    attrs |> Map.get(key)
  end

  defp extract_attr(attrs, parent_key, key) do
    attrs
    |> Map.get(parent_key)
    |> then(fn
      nil -> nil
      nested_attrs -> nested_attrs |> Map.get(key)
    end)
  end

  defp validate_operating_system(
         changeset = %{changes: %{operating_system: "linux"}}
       ) do
    changeset |> validate_required(:operating_system_detail)
  end

  defp validate_operating_system(changeset), do: changeset
end
