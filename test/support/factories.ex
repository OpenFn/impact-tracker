defmodule ImpactTracker.Factory do
  @moduledoc """
  Ex-machine factories
  """

  use ExMachina.Ecto, repo: ImpactTracker.Repo

  def instance_factory do
    %ImpactTracker.Instance{
      hashed_uuid: Base.encode16(:crypto.hash(:sha256, Ecto.UUID.generate()))
    }
  end

  def submission_factory do
    %ImpactTracker.Submission{
      generated_at: DateTime.utc_now(),
      operating_system: sequence(:operating_system, &"windows #{&1}"),
      lightning_version: sequence(:lightning_version, &"V #{&1}"),
      version: "1",
      no_of_users: sequence(:no_of_users, & &1),
      no_of_projects: sequence(:no_of_projects, & &1)
    }
  end
end
