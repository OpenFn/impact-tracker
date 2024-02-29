defmodule ImpactTracker.Repo.Migrations.AddNoOfActiveJobsToWorkflows do
  use Ecto.Migration

  def change do
    alter table(:workflows) do
      add :no_of_active_jobs, :integer, null: true
    end
  end
end
