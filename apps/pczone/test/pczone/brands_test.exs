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

    test "create post" do
      entities = Pczone.Fixtures.read_fixture("brands.yml")
      assert {:ok, {18, [brand | _]}} = Brands.upsert(entities, returning: true)
      assert {:ok, %{post: %{title: _}}} = Brands.create_post(brand.id)
    end
  end
end
