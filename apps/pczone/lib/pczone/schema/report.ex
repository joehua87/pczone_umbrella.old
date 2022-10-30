defmodule Pczone.Report do
  use Pczone.Schema
  import Ecto.Changeset

  @derive Jason.Encoder
  @timestamps_opts [type: :utc_datetime]

  @required [:name, :type, :path, :category, :size]
  @optional []

  schema "report" do
    field :name, :string
    field :type, :string
    field :path, :string
    field :category, :string
    field :size, :integer
    timestamps()
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
