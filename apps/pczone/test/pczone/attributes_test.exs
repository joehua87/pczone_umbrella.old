defmodule Pczone.AttributesTest do
  use Pczone.DataCase
  alias Pczone.Attributes

  describe "attributes" do
    @tag :wip
    test "upsert from xlsx" do
      path = Pczone.Fixtures.get_fixture_path("attributes.xlsx")

      assert {:ok,
              %{
                attribute_items: {184, nil},
                attributes: {22, _}
              }} = Attributes.upsert_from_xlsx(path)
    end
  end
end
