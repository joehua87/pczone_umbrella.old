defmodule Pczone.StoreProducts.ShopeeTest do
  use Pczone.DataCase

  import Pczone.Fixtures

  describe "upsert store products" do
    test "valid from json" do
      store = store_fixture()
      list = read_fixture("shopee-products.json")
      Pczone.StoreProducts.upsert(store.id, list)
    end
  end

  describe "upsert store variants" do
    test "valid from json" do
      store = store_fixture()
      list = read_fixture("shopee-products.json")
      product_id = "15618662714"
      {_, products} = Pczone.StoreProducts.upsert(store.id, list, returning: true)
      product = Enum.find(products, &(&1.product_code == product_id))
      detail = read_fixture("shopee-product.json")
      assert {:ok, %{variants: {27, _}}} = Pczone.StoreProducts.update(product, detail)
    end

    test "valid from id" do
      store = store_fixture()
      list = read_fixture("shopee-products.json")
      product_id = "15618662714"
      {_, products} = Pczone.StoreProducts.upsert(store.id, list, returning: true)
      product = Enum.find(products, &(&1.product_code == product_id))
      assert {:ok, %{variants: {27, _}}} = Pczone.StoreProducts.update(product.id)
    end
  end
end
