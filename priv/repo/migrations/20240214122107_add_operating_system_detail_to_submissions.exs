defmodule ImpactTracker.Repo.Migrations.AddOperatingSystemDetailToSubmissions do
  use Ecto.Migration

  def change do
    alter table(:submissions) do
      add :operating_system_detail, :string, null: true
    end
  end
end
