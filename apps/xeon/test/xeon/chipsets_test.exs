defmodule Xeon.ChipsetsTest do
  use Xeon.DataCase
  alias Xeon.Chipsets

  describe "chipsets" do
    test "upsert" do
      entities = Xeon.Fixtures.read_fixture("chipsets.yml")
      assert {53, _} = Chipsets.upsert(entities, returning: true)
    end

    test "upsert with update" do
      entities = Xeon.Fixtures.read_fixture("chipsets.yml")
      assert {53, _} = Chipsets.upsert(entities, returning: true)
      assert {53, _} = Chipsets.upsert(entities, returning: true)
    end

    test "upsert chipset processors" do
      entities = Xeon.Fixtures.read_fixture("chipsets.yml")
      assert {53, _} = Chipsets.upsert(entities, returning: true)
      assert {_, _} = "processors.yml" |> Xeon.Fixtures.read_fixture() |> Xeon.Processors.upsert()
      assert {8, _} = Chipsets.upsert_chipset_processors(entities, returning: true)
    end
  end
end
