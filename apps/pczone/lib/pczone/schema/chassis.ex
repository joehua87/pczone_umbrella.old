defmodule Pczone.Chassis do
  use Ecto.Schema
  import Ecto.Changeset

  @required [:slug, :code, :name, :form_factor, :psu_form_factors, :brand_id]
  @optional []

  schema "chassis" do
    field :slug, :string
    field :code, :string
    field :name, :string
    field :form_factor, :string
    embeds_many :hard_drive_slots, Pczone.HardDriveSlot
    field :psu_form_factors, {:array, :string}, default: []
    belongs_to :brand, Pczone.Brand
    belongs_to :post, Pczone.Post
    many_to_many :products, Pczone.Product, join_through: Pczone.ComponentProduct
  end

  def changeset(entity, params) do
    entity
    |> cast(params, @required ++ @optional)
    |> cast_embed(:hard_drive_slots)
    |> validate_required(@required)
  end

  def new_changeset(params) do
    changeset(%__MODULE__{}, params)
  end
end
