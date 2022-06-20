defmodule PcZoneWeb.Schema do
  use Absinthe.Schema

  import_types Absinthe.Plug.Types
  import_types Absinthe.Type.Custom
  import_types PcZoneWeb.Schema.Types.JSON

  import_types PcZoneWeb.Schema.Common
  import_types PcZoneWeb.Schema.Brands
  import_types PcZoneWeb.Schema.Chipsets
  import_types PcZoneWeb.Schema.Motherboards
  import_types PcZoneWeb.Schema.Barebones
  import_types PcZoneWeb.Schema.ExtensionDevices
  import_types PcZoneWeb.Schema.Processors
  import_types PcZoneWeb.Schema.Memories
  import_types PcZoneWeb.Schema.Psus
  import_types PcZoneWeb.Schema.Chassises
  import_types PcZoneWeb.Schema.HardDrives
  import_types PcZoneWeb.Schema.Gpus
  import_types PcZoneWeb.Schema.Builts
  import_types PcZoneWeb.Schema.ProductCategories
  import_types PcZoneWeb.Schema.Products
  import_types PcZoneWeb.Schema.ScrapedEntries
  import_types PcZoneWeb.Schema.SimpleBuilts

  query do
    import_fields :chipset_queries
    import_fields :processor_queries
    import_fields :chassis_queries
    import_fields :psu_queries
    import_fields :motherboard_queries
    import_fields :memory_queries
    import_fields :hard_drive_queries
    import_fields :gpu_queries
    import_fields :product_category_queries
    import_fields :product_queries
    import_fields :built_queries
    import_fields :barebone_queries
    import_fields :scraped_entry_queries
    import_fields :simple_built_queries
  end

  mutation do
    import_fields :motherboard_mutations
    import_fields :product_category_mutations
    import_fields :product_mutations
    import_fields :built_mutations
    import_fields :simple_built_mutations
  end

  def context(ctx) do
    loader =
      Dataloader.new()
      |> Dataloader.add_source(PcZoneWeb.Dataloader, PcZoneWeb.Dataloader.data(ctx))

    Map.put(ctx, :loader, loader)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end
end
