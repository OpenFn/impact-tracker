defmodule ImpactTracker.Repo.Migrations.StripVPrefixFromLightningVersion do
  use Ecto.Migration

  # Older submissions stored Lightning versions as sent, so some are
  # "v1.2.3" and some are "1.2.3". Normalise them to the un-prefixed form,
  # matching ImpactTracker.Submission.normalize_lightning_version/1.
  def up do
    execute("""
    UPDATE submissions
    SET lightning_version = substring(lightning_version FROM 2)
    WHERE lightning_version ~ '^[vV][0-9]'
    """)
  end

  # Which rows originally had a "v" isn't recorded, so this can't be undone.
  # Rolling back is a no-op rather than an error so it doesn't block
  # rolling back earlier migrations.
  def down, do: :ok
end
