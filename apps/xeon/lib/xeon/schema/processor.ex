defmodule Xeon.Processor do
  use Ecto.Schema

  schema "processor" do
    field :name, :string
    belongs_to :processor_family, Xeon.ProcessorFamily
  end
end
