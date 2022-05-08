defmodule XeonWeb.Dataloader do
  import Ecto.Query, only: [from: 2]
  alias Xeon.{Repo, Taxon}

  def data(_ctx) do
    Dataloader.Ecto.new(Repo, query: &query/2)
  end

  def query(queryable, _params) do
    IO.inspect(queryable)
    queryable
  end
end
