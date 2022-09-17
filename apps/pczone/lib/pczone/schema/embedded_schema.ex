defmodule Pczone.AttributeGroup do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @derive Jason.Encoder

  embedded_schema do
    field :title, :string
    embeds_many :items, Pczone.AttributeGroup.Attribute
  end

  defmodule Attribute do
    use Ecto.Schema

    @primary_key false
    @derive Jason.Encoder

    embedded_schema do
      field :label, :string
      field :value, :string
    end

    def changeset(entity, params) do
      cast(entity, params, [:label, :value])
    end
  end

  def changeset(entity, params) do
    cast(entity, params, [:title, :items])
  end
end

defmodule Pczone.EmbeddedMedium do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @derive Jason.Encoder

  embedded_schema do
    field :id, :string
    field :type, :string
    field :caption, :string
  end

  def changeset(entity, params) do
    entity
    |> cast(params, [:id, :type, :caption])
    |> validate_required([:id, :type])
  end
end

defmodule Pczone.Seo do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @derive Jason.Encoder

  embedded_schema do
    field :title, :string
    field :description, :string
    field :keyword, :string
    field :image, :string
    field :meta, :string
  end

  def changeset(entity, params) do
    entity
    |> cast(params, [:title, :description, :keyword, :image, :meta])
  end
end

defmodule Pczone.ProcessorSlot do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @derive Jason.Encoder

  embedded_schema do
    field :socket, :string
    field :cooler_type, :string
    field :quantity, :integer
  end

  def changeset(entity, params) do
    cast(entity, params, [:socket, :cooler_type, :quantity])
  end
end

defmodule Pczone.MemorySlot do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @derive Jason.Encoder

  embedded_schema do
    field :type, :string, primary_key: true
    field :processor_index, :integer, default: 1, primary_key: true
    field :max_capacity, :integer
    field :supported_types, {:array, :string}
    field :quantity, :integer
  end

  def changeset(entity, params) do
    cast(entity, params, [:type, :processor_index, :max_capacity, :supported_types, :quantity])
  end
end

defmodule Pczone.SataSlot do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @derive Jason.Encoder

  embedded_schema do
    field :type, :string, primary_key: true
    field :processor_index, :integer, default: 1, primary_key: true
    field :supported_types, {:array, :string}
    field :quantity, :integer
  end

  def changeset(entity, params) do
    cast(entity, params, [:type, :processor_index, :supported_types, :quantity])
  end
end

defmodule Pczone.M2Slot do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @derive Jason.Encoder

  embedded_schema do
    field :type, :string, primary_key: true
    field :processor_index, :integer, default: 1, primary_key: true
    field :supported_types, {:array, :string}
    field :form_factors, {:array, :string}
    field :quantity, :integer
  end

  def changeset(entity, params) do
    cast(entity, params, [:type, :processor_index, :supported_types, :form_factors, :quantity])
  end
end

defmodule Pczone.PciSlot do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @derive Jason.Encoder

  embedded_schema do
    field :type, :string, primary_key: true
    field :processor_index, :integer, default: 1, primary_key: true
    field :supported_types, {:array, :string}
    field :quantity, :integer
  end

  def changeset(entity, params) do
    cast(entity, params, [:type, :processor_index, :supported_types, :quantity])
  end
end

defmodule Pczone.HardDriveSlot do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @derive Jason.Encoder

  embedded_schema do
    field :form_factor, :string, primary_key: true
    field :quantity, :integer
  end

  def changeset(entity, params) do
    cast(entity, params, [:form_factor, :quantity])
  end
end
