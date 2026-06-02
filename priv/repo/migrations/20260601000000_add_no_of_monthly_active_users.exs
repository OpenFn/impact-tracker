defmodule ImpactTracker.Repo.Migrations.AddNoOfMonthlyActiveUsers do
  use Ecto.Migration

  def change do
    alter table(:submissions) do
      add :no_of_monthly_active_users, :integer, null: true
    end

    alter table(:projects) do
      add :no_of_monthly_active_users, :integer, null: true
    end
  end
end
