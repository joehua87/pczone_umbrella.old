defmodule Pczone.BuiltTemplateStoresTest do
  use Pczone.DataCase
  import Ecto.Query, only: [from: 2]
  import Pczone.Fixtures
  alias Pczone.{BuiltTemplate, BuiltTemplateStore, BuiltTemplateStores}

  describe "built template stores" do
    test "upsert", %{store: store} do
      built_templates_fixture()
      path = get_fixtures_dir() |> Path.join("built_template_stores_shopee.xlsx")

      [id_1, id_2] =
        Repo.all(
          from t in BuiltTemplate,
            where: t.code in ["hp-elitedesk-800-g2-mini-65w", "hp-elitedesk-800-g2-mini"],
            select: t.id
        )

      assert {:ok,
              {2,
               [
                 %BuiltTemplateStore{
                   id: _,
                   store_id: _,
                   product_code: "product_1",
                   built_template_id: _
                 },
                 %BuiltTemplateStore{
                   id: _,
                   store_id: _,
                   product_code: "product_2",
                   built_template_id: _
                 }
               ]}} =
               BuiltTemplateStores.upsert(
                 [
                   %{built_template_id: id_1, store_id: store.id, product_code: "product_1"},
                   %{built_template_id: id_2, store_id: store.id, product_code: "product_2"}
                 ],
                 returning: true
               )
    end

    test "upsert from xlsx", %{store: store} do
      built_templates_fixture()
      path = get_fixtures_dir() |> Path.join("built_template_stores_shopee.xlsx")

      assert {:ok,
              {2,
               [
                 %Pczone.BuiltTemplateStore{
                   id: _,
                   store_id: _,
                   product_code: "19301333605",
                   built_template_id: _
                 },
                 %Pczone.BuiltTemplateStore{
                   id: _,
                   store_id: _,
                   product_code: "15618662714",
                   built_template_id: _
                 }
               ]}} = BuiltTemplateStores.upsert_from_xlsx(store.id, path, returning: true)
    end
  end

  setup do
    get_fixtures_dir() |> Pczone.initial_data()
    {:ok, store: Pczone.Stores.get_by_code("shopee")}
  end
end
