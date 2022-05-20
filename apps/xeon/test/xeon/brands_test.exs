defmodule Xeon.BrandsTest do
  use Xeon.DataCase
  alias Xeon.Brands

  describe "brands" do
    test "upsert" do
      entities = Xeon.Fixtures.read_fixture("brands.yml")
      assert {15, _} = Brands.upsert(entities, returning: true)
    end

    test "upsert with update" do
      entities = Xeon.Fixtures.read_fixture("brands.yml")
      assert {15, _} = Brands.upsert(entities, returning: true)
      assert {15, _} = Brands.upsert(entities, returning: true)
    end
  end
end
