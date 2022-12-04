defmodule Pczone.BuiltTemplates do
  import Ecto.Query, only: [where: 2, from: 2]
  import Dew.FilterParser
  alias Pczone.{Repo, BuiltTemplate, BuiltTemplateTaxon, Taxon, Taxons}

  def get(%{} = filter) do
    Repo.one(from Pczone.BuiltTemplate, where: ^parse_filter(filter), limit: 1)
  end

  def get(id) do
    Repo.get(Pczone.BuiltTemplate, id)
  end

  def get_by_code(code) do
    Repo.one(from Pczone.BuiltTemplate, where: [code: ^code], limit: 1)
  end

  def list(attrs \\ %{})

  def list(%Dew.Filter{
        filter: filter,
        paging: paging,
        selection: selection,
        order_by: order_by
      }) do
    make_query(filter)
    |> select_fields(selection, [:media])
    |> sort_by(order_by, [])
    |> Repo.paginate(paging)
  end

  def list(attrs = %{}), do: list(struct(Dew.Filter, attrs))

  def make_query(filter) do
    Pczone.BuiltTemplate
    |> parse_taxons_filter(filter)
    |> where(^parse_filter(filter))
  end

  def update(id, params) do
    Repo.get(BuiltTemplate, id) |> BuiltTemplate.changeset(params) |> Repo.update()
  end

  def create_post(id) do
    with %{post_id: post_id, name: name} = entity when is_nil(post_id) <-
           Repo.get(Pczone.BuiltTemplate, id) do
      Ecto.Multi.new()
      |> Ecto.Multi.run(:post, fn _, _ ->
        Pczone.Posts.create(%{title: name})
      end)
      |> Ecto.Multi.run(:update, fn _, %{post: %{id: post_id}} ->
        entity |> Ecto.Changeset.change(%{post_id: post_id}) |> Repo.update()
      end)
      |> Repo.transaction()
    else
      nil -> {:error, "entity not found"}
      %{post_id: post_id} -> {:error, {"post exists", %{post_id: post_id}}}
    end
  end

  def create_posts() do
    built_templates = Repo.all(from bt in Pczone.BuiltTemplate, where: is_nil(bt.post_id))

    posts =
      Enum.map(built_templates, fn %{name: title, code: ref_code} ->
        %{
          title: title,
          slug: Slug.slugify(title),
          ref_type: "built_template",
          ref_code: ref_code
        }
      end)

    Ecto.Multi.new()
    |> Ecto.Multi.insert_all(:posts, Pczone.Post, posts, returning: true)
    |> Ecto.Multi.run(:update_ids, fn _, %{posts: {_, posts}} ->
      codes = Enum.map(posts, & &1.ref_code)

      Repo.query(
        """
        UPDATE "built_template"
        SET post_id = (SELECT id FROM post WHERE post.ref_code = built_template.code AND post.ref_type = 'built_template')
        WHERE "built_template".code = ANY($1)
        """,
        [codes]
      )
    end)
    |> Repo.transaction()
  end

  def sync_media(codes \\ []) do
    source_media_dir = "/Users/achilles/pczone/media-source"

    code_patterns =
      case codes do
        ["" <> _, _] -> "{#{Enum.join(codes, ",")}}"
        _ -> "*"
      end

    files =
      Path.join(source_media_dir, "built-templates/#{code_patterns}")
      |> Path.wildcard()
      |> Enum.map(fn path ->
        [code | _] = String.split(path, "/") |> Enum.reverse()
        media_files = Path.join(path, "*.{png,jpe?g}") |> Path.wildcard()
        uploads = Enum.map(media_files, &%{filename: Path.basename(&1), path: &1})
        media = Enum.map(uploads, &%{id: &1.filename})

        %{
          code: String.replace(code, "--", "/"),
          media: media,
          uploads: uploads
        }
      end)

    media_entities = Enum.flat_map(files, & &1.uploads)

    with {:ok, _media} <- Pczone.Media.sync_media(media_entities) do
      tmp_table_name = "table_#{DateTime.utc_now() |> DateTime.to_unix()}"

      Ecto.Multi.new()
      |> Ecto.Multi.run(:create_tmp_table, fn _, _ ->
        """
        CREATE TEMPORARY TABLE "#{tmp_table_name}" (
          code VARCHAR NOT NULL,
          media JSONB NOT NULL,
          uploads JSONB NOT NULL
        );
        """
        |> Repo.query()
      end)
      |> Ecto.Multi.insert_all(:insert_tmp_table_data, tmp_table_name, files)
      |> Ecto.Multi.run(:update_built_template_media, fn _, _ ->
        built_template_codes = Enum.map(files, & &1.code)

        Repo.query(
          """
          UPDATE built_template
          SET media = (
            SELECT media FROM #{tmp_table_name} tmp
            WHERE tmp.code = built_template.code
          )
          WHERE built_template.code = ANY($1)
          """,
          [built_template_codes]
        )
      end)
      |> Repo.transaction()
    end
  end

  def upsert(list) do
    barebone_product_codes =
      Enum.map(list, fn %{"barebone_product" => barebone_product} ->
        barebone_product
      end)
      |> Enum.uniq()

    processor_product_codes =
      Enum.flat_map(list, fn %{"processors" => processors} ->
        Enum.map(processors, & &1["processor_product"])
      end)
      |> Enum.uniq()

    gpu_product_codes =
      Enum.flat_map(list, fn %{"processors" => processors} ->
        Enum.map(processors, & &1["gpu_product"]) |> Enum.filter(&(&1 != nil))
      end)
      |> Enum.uniq()

    memory_product_codes =
      Enum.flat_map(list, fn %{"memories" => memories} ->
        Enum.map(memories, & &1["memory_product"])
      end)
      |> Enum.uniq()

    hard_drive_product_codes =
      Enum.flat_map(list, fn %{"hard_drives" => hard_drives} ->
        Enum.map(hard_drives, & &1["hard_drive_product"])
      end)
      |> Enum.uniq()

    barebone_products_map =
      Repo.all(
        from p in Pczone.Product,
          join: cp in Pczone.ComponentProduct,
          on: p.id == cp.product_id,
          where: p.code in ^barebone_product_codes,
          select: {p.code, %{id: cp.barebone_id, product_id: p.id}}
      )
      |> Enum.into(%{})

    processor_products_map =
      Repo.all(
        from p in Pczone.Product,
          join: cp in Pczone.ComponentProduct,
          on: p.id == cp.product_id,
          where: p.code in ^processor_product_codes,
          select: {p.code, %{id: cp.processor_id, product_id: p.id}}
      )
      |> Enum.into(%{})

    gpu_products_map =
      Repo.all(
        from p in Pczone.Product,
          join: cp in Pczone.ComponentProduct,
          on: p.id == cp.product_id,
          where: p.code in ^gpu_product_codes,
          select: {p.code, %{id: cp.gpu_id, product_id: p.id}}
      )
      |> Enum.into(%{})

    memory_products_map =
      Repo.all(
        from p in Pczone.Product,
          join: cp in Pczone.ComponentProduct,
          on: p.id == cp.product_id,
          where: p.code in ^memory_product_codes,
          select: {p.code, %{id: cp.memory_id, product_id: p.id}}
      )
      |> Enum.into(%{})

    hard_drive_products_map =
      Repo.all(
        from p in Pczone.Product,
          join: cp in Pczone.ComponentProduct,
          on: p.id == cp.product_id,
          where: p.code in ^hard_drive_product_codes,
          select: {p.code, %{id: cp.hard_drive_id, product_id: p.id}}
      )
      |> Enum.into(%{})

    with [] <- barebone_product_codes -- Map.keys(barebone_products_map),
         [] <- gpu_product_codes -- Map.keys(gpu_products_map),
         [] <- memory_product_codes -- Map.keys(memory_products_map),
         [] <- hard_drive_product_codes -- Map.keys(hard_drive_products_map),
         [] <- processor_product_codes -- Map.keys(processor_products_map),
         {:ok, _} <-
           Ecto.Multi.new()
           |> upsert_built_templates_multi(list, barebone_products_map)
           |> remove_built_template_references(
             :delete_built_template_processors,
             Pczone.BuiltTemplateProcessor
           )
           |> upsert_built_template_processors_multi(
             list,
             processor_products_map,
             gpu_products_map
           )
           |> remove_built_template_references(
             :delete_built_template_memories,
             Pczone.BuiltTemplateMemory
           )
           |> upsert_built_template_memories_multi(list, memory_products_map)
           |> remove_built_template_references(
             :delete_built_template_hard_drives,
             Pczone.BuiltTemplateHardDrive
           )
           |> upsert_built_template_hard_drives_multi(list, hard_drive_products_map)
           |> Repo.transaction() do
      codes = Enum.map(list, & &1["code"])

      {:ok,
       Repo.all(
         from b in Pczone.BuiltTemplate,
           where: b.code in ^codes,
           preload: [
             :barebone,
             :barebone_product,
             {:processors, [:processor, :processor_product, :gpu, :gpu_product]},
             {:memories, [:memory, :memory_product]},
             {:hard_drives, [:hard_drive, :hard_drive_product]}
           ]
       )}
    else
      [_ | _] = list -> {:error, {"Missing products", %{products: Enum.uniq(list)}}}
      reason -> reason
    end
  end

  def delete(id) do
    Repo.get(Pczone.BuiltTemplate, id) |> Repo.delete()
  end

  def delete_all_builts(built_template_id) do
    Repo.delete_all_2(from b in Pczone.Built, where: b.built_template_id == ^built_template_id)
  end

  @doc """
  Remove all built template processors
  """
  def remove_built_template_processors(built_template_id) do
    Repo.delete_all(
      from Pczone.BuiltTemplateProcessor, where: [built_template_id: ^built_template_id]
    )
  end

  @doc """
  Remove all built template memories
  """
  def remove_built_template_memories(built_template_id) do
    Repo.delete_all(
      from Pczone.BuiltTemplateMemory, where: [built_template_id: ^built_template_id]
    )
  end

  @doc """
  Remove all built template hard drives
  """
  def remove_built_template_hard_drives(built_template_id) do
    Repo.delete_all(
      from Pczone.BuiltTemplateHardDrive, where: [built_template_id: ^built_template_id]
    )
  end

  defp upsert_built_templates_multi(multi, list, barebone_products_map) do
    built_templates =
      Enum.map(
        list,
        fn %{
             "code" => code,
             "name" => name,
             "body_template" => body_template,
             "barebone_product" => barebone_product_code,
             "option_types" => option_types
           } ->
          %{
            id: barebone_id,
            product_id: barebone_product_id
          } = Map.get(barebone_products_map, barebone_product_code)

          %{
            code: code,
            name: name,
            body_template: body_template,
            barebone_id: barebone_id,
            barebone_product_id: barebone_product_id,
            option_types: option_types,
            option_value_seperator: " + "
          }
        end
      )

    Ecto.Multi.run(
      multi,
      :built_templates_map,
      fn _, _ ->
        {_, result} =
          Repo.insert_all(Pczone.BuiltTemplate, built_templates,
            returning: true,
            on_conflict:
              {:replace,
               [
                 :name,
                 :body_template,
                 :barebone_id,
                 :barebone_product_id,
                 :option_types,
                 :option_value_seperator
               ]},
            conflict_target: [:code]
          )

        {:ok,
         Enum.map(result, fn %{id: id, code: code} ->
           {code, id}
         end)
         |> Enum.into(%{})}
      end
    )
  end

  defp remove_built_template_references(multi, key, schema) do
    Ecto.Multi.run(
      multi,
      key,
      fn _, %{built_templates_map: built_templates_map} ->
        built_template_ids = Map.values(built_templates_map)

        Repo.delete_all_2(
          from bp in schema,
            where: bp.built_template_id in ^built_template_ids
        )
      end
    )
  end

  defp upsert_built_template_processors_multi(
         multi,
         list,
         processor_products_map,
         gpu_products_map
       ) do
    multi
    |> Ecto.Multi.run(
      :built_template_processors,
      fn _, %{built_templates_map: built_templates_map} ->
        entities =
          Enum.flat_map(list, fn %{"code" => code, "processors" => processors} ->
            Enum.map(
              processors,
              fn %{
                   "processor_product" => processor_product_code,
                   "processor_label" => processor_label
                 } = params ->
                %{
                  id: processor_id,
                  product_id: processor_product_id
                } = Map.get(processor_products_map, processor_product_code)

                %{
                  gpu_id: gpu_id,
                  gpu_product_id: gpu_product_id,
                  gpu_quantity: gpu_quantity
                } =
                  with "" <> gpu_product_code <- Map.get(params, "gpu_product") do
                    %{
                      id: gpu_id,
                      product_id: gpu_product_id
                    } = Map.get(gpu_products_map, gpu_product_code)

                    %{
                      gpu_id: gpu_id,
                      gpu_product_id: gpu_product_id,
                      gpu_quantity: Map.get(params, "gpu_quantity", 1)
                    }
                  else
                    _ ->
                      %{
                        gpu_id: nil,
                        gpu_product_id: nil,
                        gpu_quantity: 0
                      }
                  end

                built_template_id = Map.get(built_templates_map, code)
                processor_quantity = Map.get(params, "processor_quantity", 1)

                %{
                  built_template_id: built_template_id,
                  processor_id: processor_id,
                  processor_product_id: processor_product_id,
                  processor_quantity: processor_quantity,
                  processor_label: processor_label,
                  gpu_id: gpu_id,
                  gpu_product_id: gpu_product_id,
                  gpu_quantity: gpu_quantity,
                  gpu_label: Map.get(params, "gpu_label", "")
                }
              end
            )
          end)

        with {inserted, _} <- Repo.insert_all(Pczone.BuiltTemplateProcessor, entities) do
          {:ok, inserted}
        end
      end
    )
  end

  defp upsert_built_template_memories_multi(multi, list, memory_products_map) do
    Ecto.Multi.run(multi, :built_template_memories, fn _,
                                                       %{built_templates_map: built_templates_map} ->
      entities =
        Enum.flat_map(list, fn %{"code" => code, "memories" => memories} ->
          Enum.map(
            memories,
            fn %{"memory_product" => memory_product_code, "label" => label} = params ->
              %{
                id: memory_id,
                product_id: memory_product_id
              } = Map.get(memory_products_map, memory_product_code)

              built_template_id = Map.get(built_templates_map, code)
              quantity = Map.get(params, "quantity", 1)

              %{
                built_template_id: built_template_id,
                memory_id: memory_id,
                memory_product_id: memory_product_id,
                quantity: quantity,
                label: label
              }
            end
          )
        end)

      with {inserted, _} <- Repo.insert_all(Pczone.BuiltTemplateMemory, entities) do
        {:ok, inserted}
      end
    end)
  end

  defp upsert_built_template_hard_drives_multi(multi, list, hard_drive_products_map) do
    Ecto.Multi.run(
      multi,
      :built_template_hard_drives,
      fn _, %{built_templates_map: built_templates_map} ->
        entities =
          Enum.flat_map(list, fn %{"code" => code, "hard_drives" => hard_drives} ->
            Enum.map(
              hard_drives,
              fn %{"hard_drive_product" => hard_drive_product_code, "label" => label} = params ->
                %{
                  id: hard_drive_id,
                  product_id: hard_drive_product_id
                } = Map.get(hard_drive_products_map, hard_drive_product_code)

                built_template_id = Map.get(built_templates_map, code)
                quantity = Map.get(params, "quantity", 1)

                %{
                  built_template_id: built_template_id,
                  hard_drive_id: hard_drive_id,
                  hard_drive_product_id: hard_drive_product_id,
                  quantity: quantity,
                  label: label
                }
              end
            )
          end)

        with {inserted, _} <- Repo.insert_all(Pczone.BuiltTemplateHardDrive, entities) do
          {:ok, inserted}
        end
      end
    )
  end

  def make_builts(%Pczone.BuiltTemplate{
        id: built_template_id,
        barebone_id: barebone_id,
        barebone_product: barebone_product,
        processors: processors,
        memories: memories,
        hard_drives: hard_drives,
        option_value_seperator: seperator
      }) do
    memories_and_hard_drives =
      [%Pczone.BuiltTemplateMemory{quantity: 0, memory_product: nil} | memories]
      |> Enum.flat_map(fn %Pczone.BuiltTemplateMemory{
                            memory_id: memory_id,
                            memory_product: memory_product,
                            quantity: memory_quantity,
                            label: memory_label
                          } ->
        [%Pczone.BuiltTemplateHardDrive{quantity: 0, hard_drive_product: nil} | hard_drives]
        |> Enum.map(fn %Pczone.BuiltTemplateHardDrive{
                         hard_drive_id: hard_drive_id,
                         hard_drive_product: hard_drive_product,
                         quantity: hard_drive_quantity,
                         label: hard_drive_label
                       } ->
          memory_data =
            if(memory_product,
              do: %{
                built_memories: [
                  %{
                    memory_id: memory_id,
                    product_id: memory_product.id,
                    quantity: memory_quantity
                  }
                ]
              },
              else: %{built_memories: []}
            )

          hard_drive_data =
            if(hard_drive_product,
              do: %{
                built_hard_drives: [
                  %{
                    hard_drive_id: hard_drive_id,
                    product_id: hard_drive_product.id,
                    quantity: hard_drive_quantity
                  }
                ]
              },
              else: %{
                built_hard_drives: []
              }
            )

          %{
            option_value_2:
              Enum.join(
                [memory_label || "Ko RAM", hard_drive_label || "Ko SSD"],
                seperator
              )
          }
          |> Map.merge(memory_data)
          |> Map.merge(hard_drive_data)
        end)
      end)

    processors
    |> Enum.flat_map(fn %Pczone.BuiltTemplateProcessor{
                          processor_id: processor_id,
                          processor_product: processor_product,
                          processor_quantity: processor_quantity,
                          processor_label: processor_label,
                          gpu_id: gpu_id,
                          gpu_product: gpu_product,
                          gpu_quantity: gpu_quantity,
                          gpu_label: gpu_label
                        } ->
      gpu =
        case gpu_product do
          nil ->
            %{built_gpus: []}

          _ ->
            %{
              built_gpus: [
                %{gpu_id: gpu_id, product_id: gpu_product.id, quantity: gpu_quantity}
              ]
            }
        end

      option_value_1 =
        [processor_label, gpu_label] |> Enum.filter(&(&1 != "")) |> Enum.join(seperator)

      Enum.map(
        memories_and_hard_drives,
        fn memory_and_hard_drive = %{
             option_value_2: option_value_2
           } ->
          name = Enum.join([option_value_1, option_value_2], ",")
          slug = Slug.slugify(name)

          %{
            slug: slug,
            name: name,
            built_template_id: built_template_id,
            barebone_id: barebone_id,
            barebone_product_id: barebone_product.id,
            built_processors: [
              %{
                processor_id: processor_id,
                product_id: processor_product.id,
                quantity: processor_quantity
              }
            ],
            option_values: [option_value_1, option_value_2]
          }
          |> Map.merge(gpu)
          |> Map.merge(
            Map.drop(memory_and_hard_drive, [:option_value_2, :memory_key, :hard_drive_key])
          )
        end
      )
    end)
    |> Enum.with_index(fn item, position ->
      Map.put(item, :position, position)
    end)
  end

  def generate_builts(built_template, opts \\ [])

  def generate_builts(%BuiltTemplate{} = built_template, _opts) do
    built_template |> make_builts() |> Pczone.Builts.upsert()
  end

  def generate_builts(code, opts) when is_bitstring(code) do
    Repo.one(from t in built_template_query(), where: t.code == ^code, limit: 1)
    |> generate_builts(opts)
  end

  def generate_builts(id, opts) when is_integer(id) do
    Repo.get(built_template_query(), id)
    |> generate_builts(opts)
  end

  def generate_builts(ids, _opts) when is_list(ids) do
    built_templates = Repo.all(from bt in built_template_query(), where: bt.id in ^ids)
    built_templates |> Enum.flat_map(&make_builts/1) |> Pczone.Builts.upsert()
  end

  def generate_all_builts(opts \\ []) do
    ids = Repo.all(from t in BuiltTemplate, select: t.id)
    generate_builts(ids, opts)
  end

  def generate_content(built_template_id, template) do
    builts_query = from Pczone.Built, order_by: [asc: :position]

    built_template =
      Pczone.Repo.get(
        from(Pczone.BuiltTemplate,
          preload: [
            :barebone,
            :barebone_product,
            processors: [:processor, :processor_product, :gpu, :gpu_product],
            memories: [:memory, :memory_product],
            hard_drives: [:hard_drive, :hard_drive_product],
            builts: ^builts_query
          ]
        ),
        built_template_id
      )

    :bbmustache.render(template, built_template,
      key_type: :atom,
      value_serializer: fn
        ["" <> _ | _] = list ->
          Enum.join(list, ", ")

        x when is_integer(x) ->
          Number.Delimit.number_to_delimited(x, delimiter: ".", separator: ",", precision: 0)

        nil ->
          ""

        x ->
          x
      end
    )
  end

  def add_taxonomy(%{built_template_id: built_template_id, taxon_id: taxon_id}) do
    with %{taxonomy_id: taxonomy_id} <- Pczone.Taxons.get(taxon_id) do
      %{
        built_template_id: built_template_id,
        taxonomy_id: taxonomy_id,
        taxon_id: taxon_id
      }
      |> Pczone.BuiltTemplateTaxon.new_changeset()
      |> Repo.insert(on_conflict: :nothing)
    end
  end

  def add_taxonomies(
        %{built_template_id: built_template_id, taxon_ids: taxon_ids},
        opts \\ []
      ) do
    taxons = Repo.all(from i in Pczone.Taxon, where: i.id in ^taxon_ids)

    entities =
      Enum.map(taxons, fn %{taxonomy_id: taxonomy_id, id: taxon_id} ->
        %{
          built_template_id: built_template_id,
          taxonomy_id: taxonomy_id,
          taxon_id: taxon_id
        }
      end)

    Repo.insert_all_2(Pczone.BuiltTemplateTaxon, entities, [on_conflict: :nothing] ++ opts)
  end

  def remove_taxonomy(%{
        built_template_id: built_template_id,
        taxon_id: taxon_id
      }) do
    with entity = %{} <-
           Repo.one(
             from pa in Pczone.BuiltTemplateTaxon,
               where:
                 pa.built_template_id == ^built_template_id and
                   pa.taxon_id == ^taxon_id
           ) do
      Repo.delete(entity)
    end
  end

  def remove_taxonomies(%{
        built_template_id: built_template_id,
        taxon_ids: taxon_ids
      }) do
    Repo.delete_all_2(
      from(pa in Pczone.BuiltTemplateTaxon,
        where:
          pa.built_template_id == ^built_template_id and
            pa.taxon_id in ^taxon_ids
      ),
      on_conflict: :nothing
    )
  end

  def remove_builts() do
  end

  def parse_filter(filter) do
    filter
    |> Enum.reduce(nil, fn {field, value}, acc ->
      case field do
        :code -> parse_string_filter(acc, field, value)
        :name -> parse_string_filter(acc, field, value)
        _ -> acc
      end
    end) || true
  end

  def parse_taxons_filter(acc, %{taxons: taxons_filter_list}) do
    taxons_filter_list
    |> Enum.reduce(acc, fn taxons_filter, queryable ->
      taxon_subquery =
        from t in Taxon,
          where: ^Taxons.parse_filter(taxons_filter),
          select: t.id

      entry_subquery =
        from et in BuiltTemplateTaxon,
          where: et.taxon_id in subquery(taxon_subquery),
          distinct: et.entry_id,
          select: [:entry_id]

      from(e in queryable, join: et in subquery(entry_subquery), on: et.entry_id == e.id)
    end)
  end

  def parse_taxons_filter(acc, _), do: acc

  defp built_template_query() do
    from b in Pczone.BuiltTemplate,
      preload: [
        :barebone,
        :barebone_product,
        {:processors, [:processor_product, :gpu_product]},
        {:memories, :memory_product},
        {:hard_drives, :hard_drive_product}
      ]
  end
end
