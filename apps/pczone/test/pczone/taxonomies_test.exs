defmodule Pczone.TaxonomiesTest do
  use Pczone.DataCase
  alias Pczone.Taxonomies

  describe "taxonomies" do
    @tag :wip
    test "upsert from xlsx" do
      path = Pczone.Fixtures.get_fixture_path("taxonomies.xlsx")

      assert {:ok,
              %{
                taxons: {184, nil},
                taxonomies: {22, _}
              }} = Taxonomies.upsert_from_xlsx(path)
    end
  end
end
