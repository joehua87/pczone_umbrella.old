defmodule Xeon.MemoriesTest do
  use Xeon.DataCase
  alias Xeon.Memories

  describe "get memories" do
    test "success" do
      assert {:ok,
              %{
                memories: {7, _},
                memory_types: {3, _}
              }} = Memories.import()
    end
  end
end
