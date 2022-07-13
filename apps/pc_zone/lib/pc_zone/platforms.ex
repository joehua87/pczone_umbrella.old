defmodule PcZone.Platforms do
  def create(params) do
    params
    |> PcZone.Platform.new_changeset()
    |> PcZone.Repo.insert()
  end

  @doc """
  Upsert simple built variants for a specific platform
  """
  def upsert_simple_built_variants(platform_id, list) do
    list = list |> Enum.map(&parse_item(platform_id, &1))

    PcZone.Repo.insert_all(PcZone.SimpleBuiltVariantPlatform, list,
      conflict_target: [:platform_id, :simple_built_variant_id],
      on_conflict: {:replace, [:product_code, :variant_code]}
    )
  end

  def read_platform_simple_built_variants(path) do
    [{:ok, sheet_1} | _] = Xlsxir.multi_extract(path)
    [headers | rows] = Xlsxir.get_list(sheet_1)

    rows
    |> Enum.map(fn row ->
      row
      |> Enum.with_index(fn cell, index ->
        {Enum.at(headers, index), cell}
      end)
      |> Enum.filter(&(elem(&1, 0) != nil))
      |> Enum.into(%{})
    end)
  end

  defp parse_item(platform_id, %{
         "id" => simple_built_variant_id,
         "product_code" => product_code,
         "variant_code" => variant_code
       }) do
    %{
      platform_id: platform_id,
      simple_built_variant_id: simple_built_variant_id,
      product_code: product_code,
      variant_code: variant_code
    }
  end
end
