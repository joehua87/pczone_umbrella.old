defmodule PczoneWeb.Dataloader do
  def data(_ctx) do
    Dataloader.Ecto.new(Pczone.Repo, query: &query/2)
  end

  def query(queryable, _params) do
    queryable
  end
end
