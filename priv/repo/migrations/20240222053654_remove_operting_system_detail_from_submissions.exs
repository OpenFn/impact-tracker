defmodule ImpactTracker.Repo.Migrations.RemoveOpertingSystemDetailFromSubmissions do
  use Ecto.Migration

  def change do
    alter table(:submissions) do
      remove(:operating_system_detail, :string, null: true)
    end
  end
end
