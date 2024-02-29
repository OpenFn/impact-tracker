defmodule ImpactTracker.Repo.Migrations.AddV2FieldsToSubmissions do
  use Ecto.Migration

  def change do
    alter table(:submissions) do
      add :report_date, :date, null: true
      add :no_of_active_users, :integer, null: true
    end
  end
end
