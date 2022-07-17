defmodule Pczone.ChipsetsTest do
  use Pczone.DataCase
  alias Pczone.Chipsets

  describe "chipsets" do
    test "upsert" do
      entities = Pczone.Fixtures.read_fixture("chipsets.yml")
      assert {:ok, {53, _}} = Chipsets.upsert(entities, returning: true)
    end

    test "upsert with update" do
      entities = Pczone.Fixtures.read_fixture("chipsets.yml")
      assert {:ok, {53, _}} = Chipsets.upsert(entities, returning: true)
      assert {:ok, {53, _}} = Chipsets.upsert(entities, returning: true)
    end

    test "upsert chipset processors" do
      entities = Pczone.Fixtures.read_fixture("chipsets.yml")
      assert {:ok, {53, _}} = Chipsets.upsert(entities, returning: true)

      assert {:ok, {_, _}} =
               "processors.yml" |> Pczone.Fixtures.read_fixture() |> Pczone.Processors.upsert()

      assert {:ok, {8, _}} = Chipsets.upsert_chipset_processors(entities, returning: true)
    end
  end
end
