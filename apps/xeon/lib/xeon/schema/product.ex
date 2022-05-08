defmodule Xeon.Product do
  use Ecto.Schema

  schema "product" do
    field :slug, :string
    field :title, :string
    field :condition, :string
    field :list_price, :decimal
    field :sale_price, :decimal
    field :percentage_off, :decimal
    belongs_to :barebone, Xeon.Barebone
    belongs_to :motherboard, Xeon.Motherboard
    belongs_to :processor, Xeon.Processor
    belongs_to :memory, Xeon.Memory
    belongs_to :gpu, Xeon.Gpu
    belongs_to :hard_drive, Xeon.HardDrive
    belongs_to :psu, Xeon.Psu
    belongs_to :chassis, Xeon.Chassis
  end
end
