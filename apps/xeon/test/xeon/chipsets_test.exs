defmodule Xeon.ChipsetsTest do
  use Xeon.DataCase
  alias Xeon.Chipsets

  describe "chipsets" do
    test "upsert" do
      entities = Xeon.Fixtures.read_fixture("chipsets.yml")
      assert {53, _} = Chipsets.upsert(entities, returning: true)
    end

    test "upsert with update" do
      entities = Xeon.Fixtures.read_fixture("chipsets.yml")
      assert {53, _} = Chipsets.upsert(entities, returning: true)
      assert {53, _} = Chipsets.upsert(entities, returning: true)
    end

    test "import" do
      assert {53, _} = Chipsets.import_chipsets()
    end
  end
end
