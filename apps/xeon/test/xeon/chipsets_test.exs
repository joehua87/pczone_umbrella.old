defmodule Xeon.ChipsetsTest do
  use Xeon.DataCase
  alias Xeon.Chipsets

  describe "chipsets" do
    test "import" do
      assert {53, _} = Chipsets.import_chipsets()
    end
  end
end
