defmodule Xeon.ProcessorsTest do
  use Xeon.DataCase
  alias Xeon.Processors

  describe "processors" do
    test "import processors" do
      assert {1286, _} = Xeon.Processors.import_processors()
    end
  end
end
