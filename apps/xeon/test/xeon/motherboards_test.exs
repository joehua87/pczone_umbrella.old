defmodule Xeon.MotherboardsTest do
  use Xeon.DataCase
  alias Xeon.Motherboards

  describe "get motherboards" do
    test "success" do
      Xeon.Chipsets.import_chipsets()
      assert {154, _} = Motherboards.import_barebone_motherboards()
    end
  end
end
