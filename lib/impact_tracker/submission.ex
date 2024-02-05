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

    field :instance_id, Ecto.UUID
    field :generated_at, :utc_datetime_usec
    field :operating_system, :string
    field :lightning_version, :string
    field :version, :string
    field :no_of_users, :integer
    field :no_of_projects, :integer

    timestamps()
  end

  def new(struct, attrs) do
    submission_attrs = attrs |> extract_submission_attrs()

    attr_names = [
      :generated_at,
      :lightning_version,
      :no_of_projects,
      :no_of_users,
      :operating_system,
      :version
    ]

    struct
    |> cast(submission_attrs, attr_names)
    |> validate_required(attr_names)
    |> validate_number(:no_of_projects, greater_than_or_equal_to: 0)
    |> validate_number(:no_of_users, greater_than_or_equal_to: 0)
    |> validate_inclusion(:version, @supported_versions)
    |> cast_assoc(:projects)
  end

  defp extract_submission_attrs(attrs) do
    %{
      generated_at: attrs |> extract_attr("generated_at"),
      lightning_version: attrs |> extract_attr("instance", "version"),
      no_of_projects: attrs |> extract_attr("instance", "no_of_projects"),
      no_of_users: attrs |> extract_attr("instance", "no_of_users"),
      operating_system: attrs |> extract_attr("instance", "operating_system"),
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
end
