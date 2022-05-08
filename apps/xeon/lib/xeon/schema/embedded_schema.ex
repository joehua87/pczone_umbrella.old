defmodule Xeon.AttributeGroup do
  use Ecto.Schema

  embedded_schema do
    field :title, :string

    embeds_many :items, Attribute do
      field :label, :string
      field :value, :string
    end
  end
end

defmodule Xeon.DriveSlot do
  use Ecto.Schema

  embedded_schema do
    field :type, Ecto.Enum, values: [:sata_3_5, :sata_2_5, :msata, :nvme_3x4, :nvme_4x4]
    field :slots, :integer
  end
end

defmodule Xeon.PciSlot do
  use Ecto.Schema

  embedded_schema do
    field :type, Ecto.Enum, values: []
    field :slots, :integer
  end
end
