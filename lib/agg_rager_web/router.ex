defmodule AggRagerWeb.Router do
  use AggRagerWeb, :router
  use Coherence.Router         # Add this
  use CoherenceAssent.Router         # Add this

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session  # Add this
  end

  pipeline :protected do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session, protected: true  # Add this
  end

  # Add this block
  scope "/", AggRagerWeb do
    pipe_through :browser
    coherence_routes()
    coherence_assent_routes()        # Add this
  end

  # Add this block
  scope "/", AggRagerWeb do
    pipe_through :protected
    coherence_routes :protected
  end

  scope "/", AggRagerWeb do
    pipe_through :browser
    get "/", PageController, :index
    # Add public routes below
  end

  scope "/", AggRagerWeb do
    pipe_through :protected
    # Add protected routes below
    resources "/seasons", SeasonController, except: [:new, :edit]
  end
end