defmodule Pczone.Medium do
  use Pczone.Schema
  import Ecto.Changeset

  @primary_key {:id, :string, autogenerate: false}

  @required_fields [
    :id,
    :name,
    :ext,
    :status
  ]

  @optional_fields [
    :mime,
    :size,
    :width,
    :height,
    :remote_url,
    :blurhash,
    :derived_files,
    :caption
  ]

  @derive {Jason.Encoder, only: @required_fields ++ @optional_fields}

  schema "medium" do
    field :remote_url, :string
    field :name, :string
    field :ext, :string
    field :mime, :string
    field :caption, :string
    field :width, :decimal
    field :height, :decimal
    field :size, :decimal
    field :status, Ecto.Enum, values: [:in_process, :uploaded]
    field :blurhash, :string
    field :derived_files, {:array, :string}, default: []
    timestamps()
  end

  @doc false
  def changeset(entity, params \\ %{}) do
    entity
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

  def new(params) do
    changeset(%__MODULE__{}, params)
  end
end
