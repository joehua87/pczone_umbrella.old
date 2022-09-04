defmodule Pczone.BuiltTemplateAttribute do
  use Ecto.Schema
  import Ecto.Changeset

  @required [:built_template_id, :attribute_id, :attribute_item_id]
  @optional []

  schema "built_template_attribute" do
    belongs_to :built_template, Pczone.BuiltTemplate
    belongs_to :attribute, Pczone.Attribute
    belongs_to :attribute_item, Pczone.AttributeItem
  end

  def changeset(entity, params) do
    entity
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end

  def new_changeset(params) do
    %__MODULE__{}
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end
end
