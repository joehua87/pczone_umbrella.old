defmodule PcZone.SimpleBuildsTest do
  use PcZone.DataCase
  import PcZone.Fixtures
  import Ecto.Query, only: [from: 2]
  alias PcZone.{Repo, SimpleBuilds}

  describe "simple builds" do
    test "upsert" do
      list = PcZone.Fixtures.read_fixture("simple_builds.yml")
      assert {:ok, _} = SimpleBuilds.upsert(list)

      assert %PcZone.SimpleBuild{
               code: "hp-elitedesk-800-g2-mini",
               hard_drives: [
                 %PcZone.SimpleBuildHardDrive{},
                 %PcZone.SimpleBuildHardDrive{},
                 %PcZone.SimpleBuildHardDrive{}
               ],
               memories: [
                 %PcZone.SimpleBuildMemory{quantity: 1},
                 %PcZone.SimpleBuildMemory{quantity: 2}
               ],
               name: "Hp Elitedesk 800 G2 Mini",
               processors: [
                 %PcZone.SimpleBuildProcessor{},
                 %PcZone.SimpleBuildProcessor{},
                 %PcZone.SimpleBuildProcessor{}
               ]
             } =
               Repo.one(
                 from PcZone.SimpleBuild,
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
