defmodule Pczone.StoreProducts.ShopeeTest do
  use Pczone.DataCase

  import Pczone.Fixtures

  describe "upsert store products" do
    @tag :wip
    test "valid from json" do
      store = store_fixture()
      list = read_fixture("shopee-products.json")
      Pczone.StoreProducts.upsert(store.id, list) |> IO.inspect()
    end
  end
end
