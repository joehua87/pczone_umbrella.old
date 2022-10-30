defmodule Pczone.Barebone do
  use Pczone.Schema
  import Ecto.Changeset

  @required [:slug, :code, :name, :motherboard_id, :chassis_id, :brand_id]
  @optional [
    :processor_id,
    :launch_date,
    :psu_id,
    :raw_data,
    :source_website,
    :source_url
  ]

  schema "barebone" do
    field :slug, :string
    field :code, :string
    field :name, :string
    belongs_to :motherboard, Pczone.Motherboard
    belongs_to :chassis, Pczone.Chassis
    belongs_to :psu, Pczone.Psu
    belongs_to :processor, Pczone.Processor
    belongs_to :brand, Pczone.Brand
    belongs_to :post, Pczone.Post
    field :launch_date, :string
    field :raw_data, :map
    field :source_website, :string
    field :source_url, :string
    many_to_many :products, Pczone.Product, join_through: Pczone.ComponentProduct
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
