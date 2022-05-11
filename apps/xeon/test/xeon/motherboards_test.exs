defmodule Xeon.MotherboardsTest do
  use Xeon.DataCase
  import Ecto.Query, only: [from: 2]
  alias Xeon.{Repo, Motherboards, Motherboard}

  describe "get motherboards" do
    test "success" do
      Xeon.Chipsets.import_chipsets()
      assert {154, _} = Motherboards.import_barebone_motherboards()
    end

    test "add processor" do
      Xeon.Chipsets.import_chipsets()
      Motherboards.import_barebone_motherboards()
      Xeon.Processors.import_processors()
      motherboard = Repo.one(from Xeon.Motherboard, limit: 1)
      %{id: processor_id} = Repo.one(from Xeon.Processor, limit: 1)
      Motherboards.add_processor(%{motherboard_id: motherboard.id, processor_id: processor_id})

      assert %{processors: [%{id: ^processor_id}]} =
               Repo.get(from(Motherboard, preload: [:processors]), motherboard.id)
    end

    test "remove processor" do
      Xeon.Chipsets.import_chipsets()
      Motherboards.import_barebone_motherboards()
      Xeon.Processors.import_processors()
      motherboard = Repo.one(from Xeon.Motherboard, limit: 1)
      %{id: processor_id} = Repo.one(from Xeon.Processor, limit: 1)
      Motherboards.add_processor(%{motherboard_id: motherboard.id, processor_id: processor_id})

      assert %{processors: [%{id: ^processor_id}]} =
               Repo.get(from(Motherboard, preload: [:processors]), motherboard.id)

      Motherboards.remove_processor(%{motherboard_id: motherboard.id, processor_id: processor_id})

      assert %{processors: []} =
               Repo.get(from(Motherboard, preload: [:processors]), motherboard.id)
    end
  end
end
