defmodule ImpactTracker.Repo.Migrations.AddConstraintOnReportDate do
  use Ecto.Migration

  def change do
    create unique_index(:submissions, [:instance_id, :report_date])
  end
end
