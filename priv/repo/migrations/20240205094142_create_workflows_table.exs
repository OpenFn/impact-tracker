defmodule ImpactTracker.Repo.Migrations.CreateWorkflowsTable do
  use Ecto.Migration

  def change do
    create table(:workflows, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :project_id, references(:projects, on_delete: :delete_all, type: :binary_id),
        null: false

      add :hashed_uuid, :string, null: false
      add :cleartext_uuid, :uuid, null: true
      add :no_of_jobs, :integer, null: false
      add :no_of_runs, :integer, null: false
      add :no_of_steps, :integer, null: false

      timestamps()
    end

    create index(:workflows, :hashed_uuid, type: :hash)
    create index(:workflows, :cleartext_uuid, type: :hash)
  end
end
