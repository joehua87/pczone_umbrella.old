defmodule Pczone.MotherboardProcessor do
  use Pczone.Schema
  import Ecto.Changeset

  schema "motherboard_processor" do
    belongs_to :motherboard, Pczone.Motherboard
    belongs_to :processor, Pczone.Processor
  end

  def new_changeset(params) do
    %__MODULE__{} |> cast(params, [:motherboard_id, :processor_id])
  end
end
