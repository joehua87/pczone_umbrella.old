defmodule XeonWeb.Schema do
  use Absinthe.Schema

  import_types Absinthe.Plug.Types
  import_types Absinthe.Type.Custom
  import_types XeonWeb.Schema.Types.JSON

  import_types XeonWeb.Schema.Common
  import_types XeonWeb.Schema.Brands
  import_types XeonWeb.Schema.Chipsets
  import_types XeonWeb.Schema.Motherboards
  import_types XeonWeb.Schema.Barebones
  import_types XeonWeb.Schema.Processors
  import_types XeonWeb.Schema.Memories
  import_types XeonWeb.Schema.Psus
  import_types XeonWeb.Schema.Chassises
  import_types XeonWeb.Schema.HardDrives
  import_types XeonWeb.Schema.Gpus
  import_types XeonWeb.Schema.Builts
  import_types XeonWeb.Schema.ProductCategories
  import_types XeonWeb.Schema.Products

  query do
    import_fields :processor_queries
    import_fields :motherboard_queries
    import_fields :memory_queries
    import_fields :hard_drive_queries
    import_fields :gpu_queries
    import_fields :product_category_queries
    import_fields :product_queries
    import_fields :built_queries
    import_fields :barebone_queries
  end

  mutation do
    import_fields :motherboard_mutations
    import_fields :product_category_mutations
    import_fields :product_mutations
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
