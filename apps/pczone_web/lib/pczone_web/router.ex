defmodule PczoneWeb.Router do
  use PczoneWeb, :router

  pipeline :api do
    plug :accepts, ["json"]

    forward "/graphql", Absinthe.Plug, schema: PczoneWeb.Schema
    forward "/graphiql", Absinthe.Plug.GraphiQL, schema: PczoneWeb.Schema, interface: :playground
  end

  # Other scopes may use custom stacks.
  # scope "/api", PczoneWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: SupersoiWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  scope "/", PczoneWeb do
    pipe_through [:api]

    post "/upsert/barebones", UpsertController, :barebones
    post "/upsert/brands", UpsertController, :brands
    post "/upsert/chassises", UpsertController, :chassises
    post "/upsert/chipsets", UpsertController, :chipsets
    post "/upsert/extension-devices", UpsertController, :extension_devices
    post "/upsert/gpus", UpsertController, :gpus
    post "/upsert/hard-drives", UpsertController, :hard_drives
    post "/upsert/heatsinks", UpsertController, :heatsinks
    post "/upsert/memories", UpsertController, :memories
    post "/upsert/motherboards", UpsertController, :motherboards
    post "/upsert/processors", UpsertController, :processors
    post "/upsert/products", UpsertController, :products
    post "/upsert/psus", UpsertController, :psus
    post "/upsert/built-templates", UpsertController, :built_templates
    post "/upsert/built-template-stores", UpsertController, :built_template_stores
    post "/upsert/built-stores", UpsertController, :built_stores
  end

  scope "/files", PczoneWeb do
    pipe_through [:api]

    post "/media", FileController, :new_media
    get "/reports/*path", FileController, :report_file
    get "/media/*path", FileController, :media_file
  end
end
