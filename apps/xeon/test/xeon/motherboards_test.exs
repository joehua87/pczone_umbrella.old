defmodule Xeon.MotherboardsTest do
  use Xeon.DataCase
  alias Xeon.Motherboards

  describe "get motherboards" do
    @tag :wip
    test "success" do
      assert {:ok,
              %{
                motherboards: {19, _},
                processor_families: {6, _},
                memory_types: {14, _},
                motherboard_memory_types: {51, nil},
                motherboard_processor_families: {34, nil}
              }} = Motherboards.import()
    end
  end
end
