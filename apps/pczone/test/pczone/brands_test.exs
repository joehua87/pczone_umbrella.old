defmodule Pczone.BrandsTest do
  use Pczone.DataCase
  alias Pczone.Brands

  describe "brands" do
    test "upsert" do
      entities = Pczone.Fixtures.read_fixture("brands.yml")
      assert {:ok, {18, _}} = Brands.upsert(entities, returning: true)
    end

    test "upsert with update" do
      entities = Pczone.Fixtures.read_fixture("brands.yml")
      assert {:ok, {18, _}} = Brands.upsert(entities, returning: true)
      assert {:ok, {18, _}} = Brands.upsert(entities, returning: true)
    end
  end
end
