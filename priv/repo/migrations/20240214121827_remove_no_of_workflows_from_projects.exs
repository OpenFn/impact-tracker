defmodule ImpactTracker.Repo.Migrations.RemoveNoOfWorkflowsFromProjects do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      remove(:no_of_workflows, :integer, null: false)
    end
  end
end
