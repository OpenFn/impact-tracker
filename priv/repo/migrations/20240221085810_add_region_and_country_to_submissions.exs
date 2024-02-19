defmodule ImpactTracker.Repo.Migrations.AddRegionAndCountryToSubmissions do
  use Ecto.Migration

  def change do
    alter table(:submissions) do
      add :country, :string, null: true
      add :region, :string, null: true
    end
  end
end
