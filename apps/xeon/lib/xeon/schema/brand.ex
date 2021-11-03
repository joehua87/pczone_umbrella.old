defmodule Xeon.Brand do
  use Ecto.Schema

  schema "brand" do
    field :name, :string, null: false
  end
end
