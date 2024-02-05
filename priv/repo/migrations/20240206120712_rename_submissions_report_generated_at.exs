defmodule ImpactTracker.Repo.Migrations.RenameSubmissionsReportGeneratedAt do
  use Ecto.Migration

  def change do
    rename table("submissions"), :report_generated_at, to: :generated_at
  end
end
