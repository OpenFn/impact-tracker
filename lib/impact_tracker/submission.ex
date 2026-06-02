defmodule ImpactTracker.Submission do
  @moduledoc """
  Every time an instance submits metrics, a Submission is created.

  """
  use Ecto.Schema

  import Ecto.Changeset

  alias ImpactTracker.Project

  # When adding new versions, update this.
  @supported_versions ["1", "2", "3"]

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "submissions" do
    has_many :projects, Project

    field :country, :string
    field :generated_at, :utc_datetime_usec
    field :instance_id, Ecto.UUID
    field :lightning_version, :string
    field :no_of_active_users, :integer
    field :no_of_monthly_active_users, :integer
    field :no_of_users, :integer
    field :operating_system, :string
    field :report_date, :date
    field :region, :string
    field :version, :string

    timestamps()
  end

  def new(struct, attrs, geolocation_attrs) do
    all_attrs =
      attrs |> Map.merge(geolocation_attrs)

    struct
    |> cast(attrs, [:version])
    |> validate_required(:version)
    |> validate_inclusion(:version, @supported_versions)
    |> then(fn
      changeset = %{valid?: true} ->
        versioned_setup(changeset, all_attrs)

      changeset ->
        changeset
    end)
  end

  defp versioned_setup(changeset = %{changes: %{version: "2"}}, all_attrs) do
    build_submission(changeset, all_attrs, include_monthly_active_users: false)
  end

  # Version 3 adds a 30-day `no_of_monthly_active_users` (true MAU) alongside
  # the existing 90-day `no_of_active_users`, at both instance and project level.
  defp versioned_setup(changeset = %{changes: %{version: "3"}}, all_attrs) do
    build_submission(changeset, all_attrs, include_monthly_active_users: true)
  end

  defp build_submission(changeset, all_attrs,
         include_monthly_active_users: include_mau
       ) do
    submission_attrs =
      all_attrs |> extract_submission_attrs()

    mau_attrs = if include_mau, do: [:no_of_monthly_active_users], else: []

    cast_attrs =
      [
        :country,
        :generated_at,
        :lightning_version,
        :no_of_active_users,
        :no_of_users,
        :operating_system,
        :region,
        :report_date,
        :version
      ] ++ mau_attrs

    required_attrs =
      [
        :generated_at,
        :lightning_version,
        :no_of_active_users,
        :no_of_users,
        :operating_system,
        :report_date
      ] ++ mau_attrs

    project_changeset =
      if include_mau, do: &Project.v3_changeset/2, else: &Project.v2_changeset/2

    changeset
    |> cast(submission_attrs, cast_attrs)
    |> validate_required(required_attrs)
    |> validate_number(:no_of_active_users, greater_than_or_equal_to: 0)
    |> validate_number(:no_of_users, greater_than_or_equal_to: 0)
    |> maybe_validate_monthly_active_users(include_mau)
    |> unique_constraint(
      [:instance_id, :report_date],
      message: "instance already has a submission for this date"
    )
    |> cast_assoc(:projects, with: project_changeset)
  end

  defp maybe_validate_monthly_active_users(changeset, true) do
    validate_number(changeset, :no_of_monthly_active_users,
      greater_than_or_equal_to: 0
    )
  end

  defp maybe_validate_monthly_active_users(changeset, false), do: changeset

  defp extract_submission_attrs(attrs) do
    %{
      country: attrs |> extract_attr("country"),
      generated_at: attrs |> extract_attr("generated_at"),
      lightning_version: attrs |> extract_attr("instance", "version"),
      no_of_active_users:
        attrs |> extract_attr("instance", "no_of_active_users"),
      no_of_monthly_active_users:
        attrs |> extract_attr("instance", "no_of_monthly_active_users"),
      no_of_users: attrs |> extract_attr("instance", "no_of_users"),
      operating_system: attrs |> extract_attr("instance", "operating_system"),
      projects: attrs |> extract_attr("projects"),
      report_date: attrs |> extract_attr("report_date"),
      region: attrs |> extract_attr("region"),
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
