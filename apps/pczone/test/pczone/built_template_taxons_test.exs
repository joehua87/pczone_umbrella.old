defmodule Pczone.BuiltTemplateTaxonomiesTest do
  use Pczone.DataCase
  import Ecto.Query, only: [from: 2]
  alias Pczone.BuiltTemplates

  describe "built_template taxonomies" do
    test "add taxonomy", %{built_template: built_template} do
      taxon = Pczone.Repo.one(from Pczone.Taxon, limit: 1)

      assert {:ok, %Pczone.BuiltTemplateTaxon{}} =
               BuiltTemplates.add_taxonomy(%{
                 built_template_id: built_template.id,
                 taxon_id: taxon.id
               })
    end

    test "add taxonomies", %{built_template: built_template} do
      taxons = Pczone.Repo.all(from Pczone.Taxon, limit: 5)
      taxon_ids = Enum.map(taxons, & &1.id)

      assert {:ok, {5, [%Pczone.BuiltTemplateTaxon{} | _]}} =
               BuiltTemplates.add_taxonomies(
                 %{built_template_id: built_template.id, taxon_ids: taxon_ids},
                 returning: true
               )
    end

    test "remove taxonomy", %{built_template: built_template} do
      taxon = Pczone.Repo.one(from Pczone.Taxon, limit: 1)

      assert {:ok, %Pczone.BuiltTemplateTaxon{}} =
               BuiltTemplates.add_taxonomy(%{
                 built_template_id: built_template.id,
                 taxon_id: taxon.id
               })

      assert {:ok, %Pczone.BuiltTemplateTaxon{}} =
               BuiltTemplates.remove_taxonomy(%{
                 built_template_id: built_template.id,
                 taxon_id: taxon.id
               })
    end

    test "remove taxonomies", %{built_template: built_template} do
      taxons = Pczone.Repo.all(from Pczone.Taxon, limit: 5)
      taxon_ids = Enum.map(taxons, & &1.id)

      assert {:ok, {5, [%Pczone.BuiltTemplateTaxon{} | _]}} =
               BuiltTemplates.add_taxonomies(
                 %{built_template_id: built_template.id, taxon_ids: taxon_ids},
                 returning: true
               )

      assert {:ok, {5, _}} =
               BuiltTemplates.remove_taxonomies(%{
                 built_template_id: built_template.id,
                 taxon_ids: taxon_ids
               })
    end
  end

  setup do
    Pczone.Fixtures.get_fixtures_dir()
    |> Pczone.initial_data()

    Pczone.Fixtures.get_fixture_path("taxonomies.xlsx")
    |> Pczone.Taxonomies.upsert_from_xlsx()

    {:ok, [%Pczone.BuiltTemplate{} = built_template | _]} =
      Pczone.Fixtures.read_fixture("built_templates.yml") |> Pczone.BuiltTemplates.upsert()

    {:ok, built_template: built_template}
  end
end
