defmodule Pczone.BuiltTemplateAttribute do
  use Ecto.Schema

  schema "built_template_attribute" do
    belongs_to :built_template, Pczone.BuiltTemplate
    belongs_to :attribute, Pczone.Attribute
    belongs_to :attribute_item, Pczone.AttributeItem
  end
end
