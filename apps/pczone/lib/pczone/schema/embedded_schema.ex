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
    |> validate_required([:id])
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

defmodule Pczone.Address do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @required_fields [
    :first_name,
    :last_name,
    :full_name,
    :address1,
    :email,
    :phone,
    :province,
    :district,
    :ward,
    :region,
    :region_code
  ]
  @optional_fields [:zipcode, :address2]

  embedded_schema do
    field :first_name, :string
    field :last_name, :string
    field :full_name, :string
    field :address1, :string
    field :address2, :string
    field :email, :string
    field :phone, :string
    field :zipcode, :string
    field :province, :string
    field :district, :string
    field :ward, :string
    field :region, :string
    field :region_code, :string
  end

  def changeset(entity, attrs) do
    entity
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end

defmodule Pczone.TaxInfo do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @required_fields [:name, :tax_id, :address]
  @optional_fields [:email, :note]

  embedded_schema do
    field :name, :string
    field :tax_id, :string
    field :address, :string
    field :email, :string
    field :note, :string
  end

  def changeset(entity, attrs) do
    entity
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
