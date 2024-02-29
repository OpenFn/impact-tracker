defmodule ImpactTracker.Repo.Migrations.AddNoOfActiveUsersToProjects do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :no_of_active_users, :integer, null: true
    end
  end
end
