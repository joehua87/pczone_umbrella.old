defmodule Pczone.TaxonsTest do
  use Pczone.DataCase
  import Pczone.Fixtures
  alias Pczone.Taxons

  describe "filter taxons" do
    test "all" do
      assert %{paging: %{total_entities: 184}} = Taxons.list()
    end

    test "by taxonomy" do
      assert %{paging: %{total_entities: 62}} =
               Taxons.list(%{
                 filter: %{taxonomy: %{code: %{eq: "cpu"}}}
               })
    end
  end

  setup do
    assert {:ok, _} = get_fixture_path("taxonomies.xlsx") |> Pczone.Taxonomies.upsert_from_xlsx()
    :ok
  end
end
