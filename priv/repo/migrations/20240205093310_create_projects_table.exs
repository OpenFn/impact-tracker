defmodule ImpactTracker.Repo.Migrations.CreateProjectsTable do
  use Ecto.Migration

  def change do
    create table(:projects, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :submission_id, references(:submissions, on_delete: :delete_all, type: :binary_id),
        null: false

      add :hashed_uuid, :string, null: false
      add :cleartext_uuid, :uuid, null: true
      add :no_of_users, :integer, null: false
      add :no_of_workflows, :integer, null: false

      timestamps()
    end

    create index(:projects, :hashed_uuid, type: :hash)
    create index(:projects, :cleartext_uuid, type: :hash)
  end
end
