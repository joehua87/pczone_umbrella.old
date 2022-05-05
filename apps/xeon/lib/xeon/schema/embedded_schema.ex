defmodule Xeon.AttributeGroup do
  use Ecto.Schema

  embedded_schema do
    field :title, :string

    embeds_many :items, Attribute do
      field :label, :string
      field :value, :string
    end
  end
end
