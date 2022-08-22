defmodule PczoneWeb.Schema do
  use Absinthe.Schema

  import_types Absinthe.Plug.Types
  import_types Absinthe.Type.Custom
  import_types PczoneWeb.Schema.Types.JSON

  import_types PczoneWeb.Schema.Common
  import_types PczoneWeb.Schema.Users
  import_types PczoneWeb.Schema.Brands
  import_types PczoneWeb.Schema.Stores
  import_types PczoneWeb.Schema.Chipsets
  import_types PczoneWeb.Schema.Motherboards
  import_types PczoneWeb.Schema.Barebones
  import_types PczoneWeb.Schema.ExtensionDevices
  import_types PczoneWeb.Schema.Processors
  import_types PczoneWeb.Schema.Memories
  import_types PczoneWeb.Schema.Psus
  import_types PczoneWeb.Schema.Heatsinks
  import_types PczoneWeb.Schema.Chassises
  import_types PczoneWeb.Schema.HardDrives
  import_types PczoneWeb.Schema.Gpus
  import_types PczoneWeb.Schema.Builts
  import_types PczoneWeb.Schema.ProductCategories
  import_types PczoneWeb.Schema.Products
  import_types PczoneWeb.Schema.ScrapedEntries
  import_types PczoneWeb.Schema.BuiltTemplates
  import_types PczoneWeb.Schema.Reports
  import_types PczoneWeb.Schema.Media
  import_types PczoneWeb.Schema.App

  query do
    import_fields :user_queries
    import_fields :brand_queries
    import_fields :store_queries
    import_fields :chipset_queries
    import_fields :processor_queries
    import_fields :chassis_queries
    import_fields :psu_queries
    import_fields :heatsink_queries
    import_fields :motherboard_queries
    import_fields :memory_queries
    import_fields :hard_drive_queries
    import_fields :gpu_queries
    import_fields :product_category_queries
    import_fields :product_queries
    import_fields :built_queries
    import_fields :barebone_queries
    import_fields :scraped_entry_queries
    import_fields :built_template_queries
    import_fields :report_queries
    import_fields :medium_queries
  end

  mutation do
    import_fields :user_mutations
    import_fields :brand_mutations
    import_fields :chassis_mutations
    import_fields :chipset_mutations
    import_fields :psu_mutations
    import_fields :heatsink_mutations
    import_fields :motherboard_mutations
    import_fields :barebone_mutations
    import_fields :memory_mutations
    import_fields :processor_mutations
    import_fields :hard_drive_mutations
    import_fields :gpu_mutations
    import_fields :product_category_mutations
    import_fields :product_mutations
    import_fields :built_mutations
    import_fields :built_template_mutations
    import_fields :app_mutations

    def middleware(middleware, _field, %{}) do
      middleware ++ [PczoneWeb.Middlewares.ErrorsHandle]
    end
  end

  def context(ctx) do
    loader =
      Dataloader.new()
      |> Dataloader.add_source(PczoneWeb.Dataloader, PczoneWeb.Dataloader.data(ctx))

    Map.put(ctx, :loader, loader)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end
end
