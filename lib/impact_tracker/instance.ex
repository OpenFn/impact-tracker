defmodule ImpactTracker.Instance do
  @moduledoc """
  An instance represents an instlled Lightning instance that is
  submitting reports

  """
  use Ecto.Schema

  import Ecto.Changeset

  alias ImpactTracker.Submission

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "instances" do
    has_many :submissions, Submission

    field :cleartext_uuid, Ecto.UUID
    field :hashed_uuid, :string

    timestamps()
  end

  def new(attrs) do
    %__MODULE__{}
    |> cast(attrs["instance"], [:cleartext_uuid, :hashed_uuid])
    |> validate_required([:hashed_uuid])
    |> validate_hashed_uuid()
  end

  defp validate_hashed_uuid(changeset = %{changes: %{cleartext_uuid: cleartext}}) do
    validate_change(changeset, :hashed_uuid, fn _, hash ->
      if hash == Base.encode16(:crypto.hash(:sha256, cleartext)) do
        []
      else
        [hashed_uuid: "is not a hash of cleartext uuid"]
      end
    end)
  end

  defp validate_hashed_uuid(changeset) do
    changeset
    |> validate_format(
      :hashed_uuid,
      ~r/\A[a-z0-9]{64}\z/i,
      message: "does not appear to be valid SHA256"
    )
  end
end
