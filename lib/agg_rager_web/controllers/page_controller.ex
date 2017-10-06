defmodule AggRagerWeb.PageController do
  use AggRagerWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
