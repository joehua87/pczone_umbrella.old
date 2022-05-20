defmodule Xeon.AttributeGroup do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @derive Jason.Encoder

  embedded_schema do
    field :title, :string
    embeds_many :items, Xeon.AttributeGroup.Attribute
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

defmodule Xeon.ProcessorSlot do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @derive Jason.Encoder

  embedded_schema do
    field :socket, :string
    field :heatsink_type, :string
    field :quantity, :integer
  end

  def changeset(entity, params) do
    cast(entity, params, [:socket, :heatsink_type, :quantity])
  end
end

defmodule Xeon.MemorySlot do
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

defmodule Xeon.SataSlot do
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

defmodule Xeon.M2Slot do
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

defmodule Xeon.PciSlot do
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
