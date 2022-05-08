defmodule XeonWeb.Schema do
  use Absinthe.Schema

  import_types Absinthe.Plug.Types
  import_types Absinthe.Type.Custom
  import_types XeonWeb.Schema.Types.JSON

  import_types XeonWeb.Schema.Common
  import_types XeonWeb.Schema.Processors
  import_types XeonWeb.Schema.Motherboards

  query do
    import_fields :processor_queries
    import_fields :motherboard_queries
  end

  # mutation do
  #   import_fields :subscribers_mutations
  #   import_fields :orders_mutations
  #   import_fields :user_mutations

  #   def middleware(middleware, _field, %{}) do
  #     middleware ++ [Middlewares.ErrorsHandle]
  #   end
  # end

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
