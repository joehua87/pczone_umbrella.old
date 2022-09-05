defmodule Pczone.HardDrive do
  use Ecto.Schema
  import Ecto.Changeset

  @derive Jason.Encoder

  @required [:slug, :code, :name, :collection, :capacity, :type, :brand_id]
  @optional [:form_factor, :sequential_read, :sequential_write, :random_read, :random_write, :tbw]

  schema "hard_drive" do
    field :slug, :string
    field :code, :string
    field :name, :string
    field :collection, :string
    field :capacity, :integer
    field :type, :string
    field :form_factor, :string
    field :sequential_read, :integer
    field :sequential_write, :integer
    field :random_read, :integer
    field :random_write, :integer
    field :tbw, :integer
    belongs_to :brand, Pczone.Brand
    belongs_to :post, Pczone.Post
    many_to_many :products, Pczone.Product, join_through: Pczone.ComponentProduct
  end

  def changeset(entity, params) do
    entity
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end

  def new_changeset(params) do
    changeset(%__MODULE__{}, params)
  end
end
