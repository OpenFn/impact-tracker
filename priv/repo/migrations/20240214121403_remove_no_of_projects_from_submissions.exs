defmodule ImpactTracker.Repo.Migrations.RemoveNoOfProjectsFromSubmissions do
  use Ecto.Migration

  def change do
    alter table(:submissions) do
      remove(:no_of_projects, :integer, null: false)
    end
  end
end
