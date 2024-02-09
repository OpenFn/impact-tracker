defmodule ImpactTracker.InstanceTest do
  use ImpactTracker.DataCase

  alias Ecto.Changeset
  alias ImpactTracker.Instance

  describe ".new/1" do
    test "returns a valid changeset with valid data" do
      report = build_report()

      %{
        "instance" => %{
          "cleartext_uuid" => cleartext,
          "hashed_uuid" => hashed
        }
      } = report

      changeset = report |> Instance.new()

      assert %Changeset{valid?: true, changes: changes} = changeset

      assert %{cleartext_uuid: ^cleartext, hashed_uuid: ^hashed} = changes
    end

    test "validates that the hashed_uuid is present" do
      report = build_report(uuids_required: :cleartext)

      changeset = report |> Instance.new()

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert [hashed_uuid: {"can't be blank", [validation: :required]}] =
               errors
    end

    test "validates that hash is sha256 of cleartext if cleartext present" do
      report = build_report(hash: hash("foo"))

      changeset = report |> Instance.new()

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert [hashed_uuid: {"is not a hash of cleartext uuid", []}] = errors
    end

    test "validates that hash is the correct format if cleartext is absent" do
      report =
        build_report(uuids_required: :hashed, hash: correct_format_hash())

      changeset = report |> Instance.new()
      assert %Changeset{valid?: true} = changeset

      report =
        build_report(uuids_required: :hashed, hash: short_1_char_hash())

      changeset = report |> Instance.new()
      assert_incorrectly_formatted_hash(changeset)

      report = build_report(uuids_required: :hashed, hash: extra_1_char_hash())
      changeset = report |> Instance.new()
      assert_incorrectly_formatted_hash(changeset)

      report =
        build_report(uuids_required: :hashed, hash: non_alphanum_char_hash())

      changeset = report |> Instance.new()
      assert_incorrectly_formatted_hash(changeset)
    end

    test "validates that the cleartext_uuid is a well-formed UUID" do
      report = build_report(uuid: "1-a-b-c")

      changeset = report |> Instance.new()

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert [
               cleartext_uuid: {
                 "is invalid",
                 [{:type, Ecto.UUID}, {:validation, :cast}]
               }
             ] = errors
    end
  end

  defp generate_uuid do
    Ecto.UUID.generate()
  end

  defp build_report(config \\ []) do
    uuids_required = config |> Keyword.get(:uuids_required, :both)
    uuid = config |> Keyword.get(:uuid, generate_uuid())
    hash = config |> Keyword.get(:hash, hash(uuid))

    %{
      "instance" => {uuid, hash} |> build_identity_object(uuids_required)
    }
  end

  defp build_identity_object({uuid, hash}, uuids_required) do
    %{}
    |> Map.merge(build_hashed_uuid(uuids_required, hash))
    |> Map.merge(build_cleartext_uuid(uuids_required, uuid))
  end

  defp build_hashed_uuid(:cleartext, _hash), do: %{"hashed_uuid" => nil}
  defp build_hashed_uuid(_, hash), do: %{"hashed_uuid" => hash}

  defp build_cleartext_uuid(:hashed, _uuid), do: %{"cleartext_uuid" => nil}
  defp build_cleartext_uuid(_, uuid), do: %{"cleartext_uuid" => uuid}

  defp hash(uuid), do: Base.encode16(:crypto.hash(:sha256, uuid))

  defp correct_format_hash, do: String.duplicate("a1Db", 16)

  defp short_1_char_hash, do: String.duplicate("a1D", 21)

  defp extra_1_char_hash, do: String.duplicate("a1dB", 16) <> "x"

  defp non_alphanum_char_hash, do: String.duplicate("a1D", 21) <> "="

  defp assert_incorrectly_formatted_hash(changeset) do
    assert %Changeset{valid?: false, errors: errors} = changeset

    assert [
             hashed_uuid: {
               "does not appear to be valid SHA256",
               [validation: :format]
             }
           ] = errors
  end
end
