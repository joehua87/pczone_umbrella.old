defmodule Pczone.BuiltTemplateStores do
  import Ecto.Query, only: [from: 2]

  alias Pczone.{
    Helpers,
    Repo,
    BuiltTemplate,
    Xlsx
  }

  def upsert(entities, opts \\ []) when is_list(entities) do
    with list = [_ | _] <-
           Pczone.Helpers.get_list_changset_changes(entities, fn entity ->
             Pczone.BuiltTemplateStore.new_changeset(entity)
             |> Pczone.Helpers.get_changeset_changes()
           end) do
      Repo.insert_all_2(
        Pczone.BuiltTemplateStore,
        list,
        Keyword.merge(opts,
          on_conflict: {:replace, [:product_code]},
          conflict_target: [:built_template_id, :store_id]
        )
      )
    end
  end

  def upsert_from_xlsx(path, opts \\ []) do
    list =
      path
      |> Xlsx.read_spreadsheet()
      |> Enum.reduce(
        [],
        fn
          %{
            "product_code" => product_code,
            "built_template_code" => built_template_code,
            "store_code" => store_code
          },
          acc
          when is_binary(built_template_code) ->
            acc ++
              [
                %{
                  product_code: Helpers.ensure_string(product_code),
                  built_template_code: String.trim(built_template_code),
                  store_code: store_code
                }
              ]

          _, acc ->
            acc
        end
      )

    built_template_codes = Enum.map(list, & &1.built_template_code)
    store_codes = Enum.map(list, & &1.store_code)

    built_templates_map =
      from(b in BuiltTemplate, where: b.code in ^built_template_codes, select: {b.code, b.id})
      |> Repo.all()
      |> Enum.into(%{})

    stores_map =
      from(b in Pczone.Store, where: b.code in ^store_codes, select: {b.code, b.id})
      |> Repo.all()
      |> Enum.into(%{})

    list =
      Enum.map(list, fn %{
                          product_code: product_code,
                          built_template_code: built_template_code,
                          store_code: store_code
                        } ->
        %{
          store_id: stores_map[store_code],
          built_template_id: built_templates_map[built_template_code],
          product_code: product_code
        }
      end)
      |> Enum.filter(&(&1.built_template_id != nil))

    Repo.insert_all_2(
      Pczone.BuiltTemplateStore,
      list,
      [
        on_conflict: {:replace, [:product_code]},
        conflict_target: [:built_template_id, :store_id]
      ] ++ opts
    )
  end
end
