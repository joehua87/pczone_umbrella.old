defmodule Xeon.MotherboardProcessor do
  use Ecto.Schema
  import Ecto.Changeset

  schema "motherboard_processor" do
    belongs_to :motherboard, Xeon.Motherboard
    belongs_to :processor, Xeon.Processor
  end

  def new_changeset(params) do
    %__MODULE__{} |> cast(params, [:motherboard_id, :processor_id])
  end
end
