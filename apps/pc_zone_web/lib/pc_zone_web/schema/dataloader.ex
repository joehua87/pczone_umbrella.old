defmodule PcZoneWeb.Dataloader do
  def data(_ctx) do
    Dataloader.Ecto.new(PcZone.Repo, query: &query/2)
  end

  def query(queryable, _params) do
    queryable
  end
end
