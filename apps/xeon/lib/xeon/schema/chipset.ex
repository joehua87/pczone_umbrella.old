defmodule Xeon.Chipset do
  use Ecto.Schema

  schema "chipset" do
    field :shortname, :string
    field :code_name, :string
    field :name, :string
    field :launch_date, :string
    field :collection_name, :string
    field :vertical_segment, :string
    field :status, :string
    embeds_many :attributes, Xeon.AttributeGroup
  end
end
