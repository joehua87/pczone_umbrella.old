defmodule Pczone.BuiltTemplatesTest do
  use Pczone.DataCase
  import Ecto.Query, only: [from: 2]
  import Pczone.Fixtures
  alias Pczone.{Repo, BuiltTemplates}

  describe "built templates" do
    test "upsert" do
      list = Pczone.Fixtures.read_fixture("built_templates.yml")
      {:ok, [%Pczone.BuiltTemplate{} | _]} = Pczone.BuiltTemplates.upsert(list)

      assert %{
               processors: [
                 %{processor_label: "i3-9100", gpu_label: ""},
                 %{processor_label: "i3-9100F", gpu_label: "K600", gpu: %{}, gpu_product: %{}}
               ]
             } =
               Repo.one(
                 from Pczone.BuiltTemplate,
                   preload: [:processors],
                   where: [code: "dell-optiplex-7060-sff"]
               )
    end

    test "remove built template processors" do
      list = Pczone.Fixtures.read_fixture("built_templates.yml")

      {:ok, [%Pczone.BuiltTemplate{id: built_template_id} | _]} =
        Pczone.BuiltTemplates.upsert(list)

      Pczone.BuiltTemplates.remove_built_template_processors(built_template_id)

      assert %{processors: []} =
               Repo.get(from(Pczone.BuiltTemplate, preload: [:processors]), built_template_id)
    end

    test "remove built template memories" do
      list = Pczone.Fixtures.read_fixture("built_templates.yml")

      {:ok, [%Pczone.BuiltTemplate{id: built_template_id} | _]} =
        Pczone.BuiltTemplates.upsert(list)

      Pczone.BuiltTemplates.remove_built_template_memories(built_template_id)

      assert %{memories: []} =
               Repo.get(from(Pczone.BuiltTemplate, preload: [:memories]), built_template_id)
    end

    test "remove built template hard_drives" do
      list = Pczone.Fixtures.read_fixture("built_templates.yml")

      {:ok, [%Pczone.BuiltTemplate{id: built_template_id} | _]} =
        Pczone.BuiltTemplates.upsert(list)

      Pczone.BuiltTemplates.remove_built_template_hard_drives(built_template_id)

      assert %{hard_drives: []} =
               Repo.get(from(Pczone.BuiltTemplate, preload: [:hard_drives]), built_template_id)
    end

    test "make builts" do
      [built_template | _] = built_templates_fixture()

      assert [
               %{
                 barebone_id: _,
                 barebone_product_id: _,
                 built_gpus: [],
                 built_hard_drives: [],
                 built_memories: [],
                 built_processors: [%{processor_id: _, product_id: _, quantity: 1}],
                 built_template_id: _,
                 name: "i5-6500T,Ko RAM + Ko SSD",
                 option_values: ["i5-6500T", "Ko RAM + Ko SSD"],
                 position: 0,
                 slug: "i5-6500t-ko-ram-ko-ssd"
               }
               | _
             ] = BuiltTemplates.make_builts(built_template)
    end

    test "generate builts" do
      [built_template | _] = built_templates_fixture()
      assert {:ok, _} = BuiltTemplates.generate_builts(built_template)

      assert [%{price: 3_500_000} | _] =
               Repo.all(
                 from v in Pczone.Built, where: v.state == :published, order_by: [asc: :position]
               )
    end

    test "update variants state when built template processors changed" do
      [built_template | _] = built_templates_fixture()
      assert {:ok, _} = BuiltTemplates.generate_builts(built_template)
      assert {_, nil} = BuiltTemplates.remove_built_template_processors(built_template.id)
      assert {:ok, _} = BuiltTemplates.generate_builts(built_template.code, returning: true)
      assert [] = Repo.all(from v in Pczone.Built, where: v.state == :published)
    end

    test "create post" do
      [built_template | _] = built_templates_fixture()
      assert {:ok, %{post: %{title: _}}} = Pczone.BuiltTemplates.create_post(built_template.id)
    end

    test "generate content" do
      [built_template | _] = built_templates_fixture()
      assert {:ok, _} = BuiltTemplates.generate_builts(built_template)

      template = """
      # {{name}}

      ## Hỗ trợ CPU:

      {{#processors}}
      - {{processor.code}} ({{processor.cores}} cores {{processor.threads}} threads)
      {{/processors}}

      ## Bảng giá chi tiết:

      {{#builts}}
      * {{option_values}}: {{price}}
      {{/builts}}
      """

      # TODO: Findout when string is not equal even if look like equal
      assert """
             # Hp Elitedesk 800 G2 Mini
             """ <> _ = _content = BuiltTemplates.generate_content(built_template.id, template)
    end
  end

  setup do
    get_fixtures_dir()
    |> Pczone.initial_data()

    :ok
  end
end
