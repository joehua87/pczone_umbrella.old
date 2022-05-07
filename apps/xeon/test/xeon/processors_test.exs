defmodule Xeon.ProcessorsTest do
  use Xeon.DataCase

  describe "processors" do
    test "import processors" do
      assert {1286, _} = Xeon.Processors.import_processors()
    end

    test "import processor chipsets" do
      assert {_, _} = Xeon.Processors.import_processors()
      assert {_, _} = Xeon.Chipsets.import_chipsets()
      assert {1709, nil} = Xeon.Processors.import_processor_chipsets()
    end
  end
end
