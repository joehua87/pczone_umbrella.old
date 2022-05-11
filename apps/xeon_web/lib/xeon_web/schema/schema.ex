defmodule XeonWeb.Schema do
  use Absinthe.Schema

  import_types Absinthe.Plug.Types
  import_types Absinthe.Type.Custom
  import_types XeonWeb.Schema.Types.JSON

  import_types XeonWeb.Schema.Common
  import_types XeonWeb.Schema.Brands
  import_types XeonWeb.Schema.Chipsets
  import_types XeonWeb.Schema.Motherboards
  import_types XeonWeb.Schema.Processors
  import_types XeonWeb.Schema.Memories
  import_types XeonWeb.Schema.Builts
  import_types XeonWeb.Schema.Products

  query do
    import_fields :processor_queries
    import_fields :motherboard_queries
    import_fields :built_queries
  end

  mutation do
    import_fields :motherboard_mutations
  end

  def context(ctx) do
    loader =
      Dataloader.new()
      |> Dataloader.add_source(XeonWeb.Dataloader, XeonWeb.Dataloader.data(ctx))

    Map.put(ctx, :loader, loader)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end
end
