defmodule ImpactTracker.Repo.Migrations.CreateReportingInstancesTable do
  use Ecto.Migration

  def change do
    create table(:instances, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :hashed_uuid, :string, null: false
      add :cleartext_uuid, :uuid, null: true

      timestamps()
    end

    create unique_index(:instances, :hashed_uuid)
    create unique_index(:instances, :cleartext_uuid, nulls_distinct: true)
  end
end
