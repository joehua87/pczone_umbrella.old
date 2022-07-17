defmodule Pczone.Repo do
  use Ecto.Repo,
    otp_app: :pczone,
    adapter: Ecto.Adapters.Postgres

  @scrivener_defaults [page_size: 24]

  def paginate(pageable, options \\ []) do
    Scrivener.paginate(
      pageable,
      Scrivener.Config.new(__MODULE__, @scrivener_defaults, options)
    )
    |> parse_list_result()
  end

  def insert_all_2(schema, list, opts \\ []) do
    case insert_all(schema, list, opts) do
      {:error, reason} -> {:error, reason}
      {inserted, list} -> {:ok, {inserted, list}}
    end
  end

  defp parse_list_result(%{
         entries: entries,
         page_number: page_number,
         page_size: page_size,
         total_entries: total_entries,
         total_pages: total_pages
       }) do
    %{
      entities: entries,
      paging: %{
        page: page_number,
        page_number: page_number,
        page_size: page_size,
        total_entities: total_entries,
        total_pages: total_pages
      }
    }
  end
end

Postgrex.Types.define(
  Pczone.PostgresTypes,
  [EctoLtree.Postgrex.Lquery, EctoLtree.Postgrex.Ltree] ++ Ecto.Adapters.Postgres.extensions()
)
