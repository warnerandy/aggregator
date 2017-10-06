defmodule AggRagerWeb.PageController do
  use AggRagerWeb, :controller

  require Logger

  def index(conn, _params) do
  	user = Coherence.current_user(conn)
    Logger.info "test"
    Logger.info inspect conn
    render conn, "index.html"
  end
end
