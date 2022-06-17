defmodule PcZone.SimpleBuiltsTest do
  use PcZone.DataCase
  import PcZone.Fixtures
  import Ecto.Query, only: [from: 2]
  alias PcZone.{Repo, SimpleBuilts}

  describe "simple builds" do
    test "upsert" do
      list = PcZone.Fixtures.read_fixture("simple_builts.yml")
      assert {:ok, _} = SimpleBuilts.upsert(list)

      assert %PcZone.SimpleBuilt{
               code: "hp-elitedesk-800-g2-mini",
               hard_drives: [
                 %PcZone.SimpleBuiltHardDrive{},
                 %PcZone.SimpleBuiltHardDrive{},
                 %PcZone.SimpleBuiltHardDrive{}
               ],
               memories: [
                 %PcZone.SimpleBuiltMemory{quantity: 1},
                 %PcZone.SimpleBuiltMemory{quantity: 2}
               ],
               name: "Hp Elitedesk 800 G2 Mini",
               processors: [
                 %PcZone.SimpleBuiltProcessor{},
                 %PcZone.SimpleBuiltProcessor{},
                 %PcZone.SimpleBuiltProcessor{}
               ]
             } =
               Repo.one(
                 from PcZone.SimpleBuilt,
                   preload: [:processors, :memories, :hard_drives],
                   limit: 1
               )
    end
  end

  setup do
    get_fixtures_dir()
    |> PcZone.initial_data()

    :ok
  end
end
