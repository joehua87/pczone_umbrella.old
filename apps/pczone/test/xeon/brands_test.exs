defmodule PcZone.BrandsTest do
  use PcZone.DataCase
  alias PcZone.Brands

  describe "brands" do
    test "upsert" do
      entities = PcZone.Fixtures.read_fixture("brands.yml")
      assert {16, _} = Brands.upsert(entities, returning: true)
    end

    test "upsert with update" do
      entities = PcZone.Fixtures.read_fixture("brands.yml")
      assert {16, _} = Brands.upsert(entities, returning: true)
      assert {16, _} = Brands.upsert(entities, returning: true)
    end
  end
end
