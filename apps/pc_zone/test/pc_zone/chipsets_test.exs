defmodule PcZone.ChipsetsTest do
  use PcZone.DataCase
  alias PcZone.Chipsets

  describe "chipsets" do
    test "upsert" do
      entities = PcZone.Fixtures.read_fixture("chipsets.yml")
      assert {:ok, {53, _}} = Chipsets.upsert(entities, returning: true)
    end

    test "upsert with update" do
      entities = PcZone.Fixtures.read_fixture("chipsets.yml")
      assert {:ok, {53, _}} = Chipsets.upsert(entities, returning: true)
      assert {:ok, {53, _}} = Chipsets.upsert(entities, returning: true)
    end

    test "upsert chipset processors" do
      entities = PcZone.Fixtures.read_fixture("chipsets.yml")
      assert {:ok, {53, _}} = Chipsets.upsert(entities, returning: true)

      assert {:ok, {_, _}} =
               "processors.yml" |> PcZone.Fixtures.read_fixture() |> PcZone.Processors.upsert()

      assert {:ok, {8, _}} = Chipsets.upsert_chipset_processors(entities, returning: true)
    end
  end
end
