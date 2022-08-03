defmodule Pczone.SimpleBuiltsTest do
  use Pczone.DataCase
  import Ecto.Query, only: [from: 2]
  import Pczone.Fixtures
  alias Pczone.{Repo, SimpleBuilts}

  describe "simple builts" do
    test "upsert" do
      list = Pczone.Fixtures.read_fixture("simple_builts.yml")
      {:ok, [%Pczone.SimpleBuilt{} | _]} = Pczone.SimpleBuilts.upsert(list)

      assert %{
               processors: [
                 %{processor_label: "i3-9100", gpu_label: ""},
                 %{processor_label: "i3-9100F", gpu_label: "K600", gpu: %{}, gpu_product: %{}}
               ]
             } =
               Repo.one(
                 from Pczone.SimpleBuilt,
                   preload: [:processors],
                   where: [code: "dell-optiplex-7060-sff"]
               )
    end

    test "remove simple built processors" do
      list = Pczone.Fixtures.read_fixture("simple_builts.yml")
      {:ok, [%Pczone.SimpleBuilt{id: simple_built_id} | _]} = Pczone.SimpleBuilts.upsert(list)
      Pczone.SimpleBuilts.remove_simple_built_processors(simple_built_id)

      assert %{processors: []} =
               Repo.get(from(Pczone.SimpleBuilt, preload: [:processors]), simple_built_id)
    end

    test "remove simple built memories" do
      list = Pczone.Fixtures.read_fixture("simple_builts.yml")
      {:ok, [%Pczone.SimpleBuilt{id: simple_built_id} | _]} = Pczone.SimpleBuilts.upsert(list)
      Pczone.SimpleBuilts.remove_simple_built_memories(simple_built_id)

      assert %{memories: []} =
               Repo.get(from(Pczone.SimpleBuilt, preload: [:memories]), simple_built_id)
    end

    test "remove simple built hard_drives" do
      list = Pczone.Fixtures.read_fixture("simple_builts.yml")
      {:ok, [%Pczone.SimpleBuilt{id: simple_built_id} | _]} = Pczone.SimpleBuilts.upsert(list)
      Pczone.SimpleBuilts.remove_simple_built_hard_drives(simple_built_id)

      assert %{hard_drives: []} =
               Repo.get(from(Pczone.SimpleBuilt, preload: [:hard_drives]), simple_built_id)
    end

    test "generate simple built variants" do
      [simple_built | _] = simple_builts_fixture()
      assert {:ok, _} = SimpleBuilts.generate_variants(simple_built)
    end

    test "update variants state when simple built processors changed" do
      [simple_built | _] = simple_builts_fixture()
      assert {:ok, _} = SimpleBuilts.generate_variants(simple_built)
      assert {_, nil} = SimpleBuilts.remove_simple_built_processors(simple_built.id)
      assert {:ok, {0, []}} = SimpleBuilts.generate_variants(simple_built.code, returning: true)
      assert [] = Repo.all(from v in Pczone.SimpleBuiltVariant, where: v.state == :active)
    end

    test "generate content" do
      [simple_built | _] = simple_builts_fixture()
      assert {:ok, {_, _}} = SimpleBuilts.generate_variants(simple_built)

      template = """
      # {{name}}

      ## Hỗ trợ CPU:

      {{#processors}}
      - {{processor.code}} ({{processor.cores}} cores {{processor.threads}} threads)
      {{/processors}}

      ## Bảng giá chi tiết:

      {{#variants}}
      * {{option_values}}: {{total}}
      {{/variants}}
      """

      # TODO: Findout when string is not equal even if look like equal
      assert """
             # Hp Elitedesk 800 G2 Mini
             """ <> _ = _content = SimpleBuilts.generate_content(simple_built.id, template)
    end
  end

  setup do
    get_fixtures_dir()
    |> Pczone.initial_data()

    :ok
  end
end
