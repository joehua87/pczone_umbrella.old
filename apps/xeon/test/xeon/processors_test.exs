defmodule Xeon.ProcessorsTest do
  use Xeon.DataCase
  alias Xeon.Processors

  describe "get processors" do
    test "success" do
      assert [%{name: _, links: %{}} | _] = Xeon.Processors.get_processors()
    end

    test "import processors" do
      assert {_, _} = Xeon.Processors.import_processors()
    end
  end

  describe "get_processor" do
    test "get processor" do
      assert %{
               cores: 4,
               family_code: "Tiger Lake",
               frequency: 3100,
               gpu: "Intel Iris Xe Graphics",
               maximum_frequency: 4400,
               name: "Intel Core i5-11300H",
               socket: "FCBGA1449",
               threads: 8,
               scores: %{multi: 4386, single: 1299}
             } =
               Xeon.Processors.get_processor(
                 "https://browser.geekbench.com/processors/intel-core-i5-11300h"
               )
    end

    test "update processor" do
      {:ok, processor} =
        Processors.create(%{
          name: "Intel Core i5-11300H",
          links: %{"geekbench" => "https://browser.geekbench.com/processors/intel-core-i5-11300h"}
        })

      assert {:ok,
              %{
                processor: %Xeon.Processor{
                  cores: 4,
                  family_code: "Tiger Lake",
                  frequency: 3100,
                  gpu: "Intel Iris Xe Graphics",
                  links: %{
                    "geekbench" => "https://browser.geekbench.com/processors/intel-core-i5-11300h"
                  },
                  maximum_frequency: 4400,
                  meta: %{},
                  name: "Intel Core i5-11300H",
                  processor_collection_id: nil,
                  socket: "FCBGA1449",
                  tdp: nil,
                  threads: 8
                },
                processor_score: %Xeon.ProcessorScore{
                  multi: 4386,
                  single: 1299,
                  test_name: "geekbench5"
                }
              }} = Processors.get_detail(processor)
    end
  end
end
