defmodule PcZone.Barebone do
  use Ecto.Schema
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
    belongs_to :motherboard, PcZone.Motherboard
    belongs_to :chassis, PcZone.Chassis
    belongs_to :psu, PcZone.Psu
    belongs_to :processor, PcZone.Processor
    belongs_to :brand, PcZone.Brand
    field :launch_date, :string
    field :raw_data, :map
    field :source_website, :string
    field :source_url, :string
    has_many :products, PcZone.Product
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
