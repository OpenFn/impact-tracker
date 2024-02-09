defmodule ImpactTracker.Repo.Migrations.AddSubmissionsTable do
  use Ecto.Migration

  def change do
    create table(:submissions, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :instance_id, references(:instances, on_delete: :delete_all, type: :binary_id),
        null: false

      add :report_generated_at, :utc_datetime_usec, null: false
      add :operating_system, :string, null: false
      add :lightning_version, :string, null: false
      add :version, :string, null: false
      add :no_of_users, :integer, null: false
      add :no_of_projects, :integer, null: false

      timestamps()
    end
  end
end
