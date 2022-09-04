defmodule Pczone.BuiltTemplateAttributesTest do
  use Pczone.DataCase
  import Ecto.Query, only: [from: 2]
  alias Pczone.BuiltTemplates

  describe "built_template attributes" do
    test "add attribute", %{built_template: built_template} do
      attribute_item = Pczone.Repo.one(from Pczone.AttributeItem, limit: 1)

      assert {:ok, %Pczone.BuiltTemplateAttribute{}} =
               BuiltTemplates.add_attribute(%{
                 built_template_id: built_template.id,
                 attribute_item_id: attribute_item.id
               })
    end

    test "add attributes", %{built_template: built_template} do
      attribute_items = Pczone.Repo.all(from Pczone.AttributeItem, limit: 5)
      attribute_item_ids = Enum.map(attribute_items, & &1.id)

      assert {:ok, {5, [%Pczone.BuiltTemplateAttribute{} | _]}} =
               BuiltTemplates.add_attributes(
                 %{built_template_id: built_template.id, attribute_item_ids: attribute_item_ids},
                 returning: true
               )
    end

    test "remove attribute", %{built_template: built_template} do
      attribute_item = Pczone.Repo.one(from Pczone.AttributeItem, limit: 1)

      assert {:ok, %Pczone.BuiltTemplateAttribute{}} =
               BuiltTemplates.add_attribute(%{
                 built_template_id: built_template.id,
                 attribute_item_id: attribute_item.id
               })

      assert {:ok, %Pczone.BuiltTemplateAttribute{}} =
               BuiltTemplates.remove_attribute(%{
                 built_template_id: built_template.id,
                 attribute_item_id: attribute_item.id
               })
    end

    test "remove attributes", %{built_template: built_template} do
      attribute_items = Pczone.Repo.all(from Pczone.AttributeItem, limit: 5)
      attribute_item_ids = Enum.map(attribute_items, & &1.id)

      assert {:ok, {5, [%Pczone.BuiltTemplateAttribute{} | _]}} =
               BuiltTemplates.add_attributes(
                 %{built_template_id: built_template.id, attribute_item_ids: attribute_item_ids},
                 returning: true
               )

      assert {:ok, {5, _}} =
               BuiltTemplates.remove_attributes(%{
                 built_template_id: built_template.id,
                 attribute_item_ids: attribute_item_ids
               })
    end
  end

  setup do
    Pczone.Fixtures.get_fixtures_dir()
    |> Pczone.initial_data()

    Pczone.Fixtures.get_fixture_path("attributes.xlsx")
    |> Pczone.Attributes.upsert_from_xlsx()

    {:ok, [%Pczone.BuiltTemplate{} = built_template | _]} =
      Pczone.Fixtures.read_fixture("built_templates.yml") |> Pczone.BuiltTemplates.upsert()

    {:ok, built_template: built_template}
  end
end
