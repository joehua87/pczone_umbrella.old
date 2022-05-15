defmodule Xeon.Barebone do
  use Ecto.Schema
  import Ecto.Changeset

  @required [:name, :motherboard_id, :chassis_id]
  @optional [
    :brand_id,
    :launch_date,
    :psu_options,
    :psu_id,
    :raw_data,
    :source_website,
    :source_url
  ]

  schema "barebone" do
    field :name, :string
    belongs_to :motherboard, Xeon.Motherboard
    belongs_to :chassis, Xeon.Chassis
    belongs_to :psu, Xeon.Psu
    belongs_to :brand, Xeon.Brand
    field :psu_options, {:array, :integer}
    field :launch_date, :string
    field :raw_data, :map
    field :source_website, :string
    field :source_url, :string
    has_many :products, Xeon.Product
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
