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
    post "/upsert/products", UpsertController, :products
  end

  scope "/files", PczoneWeb do
    pipe_through [:api]

    post "/media", FileController, :new_media
    get "/reports/*path", FileController, :report_file
    get "/media/*path", FileController, :media_file
  end
end
