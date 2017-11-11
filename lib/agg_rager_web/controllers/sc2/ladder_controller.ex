defmodule AggRagerWeb.SC2.LadderController do
  use AggRagerWeb, :controller

  require Logger

  def index(conn, params) do
    player = get_session(conn, :player)
    client = get_session(conn, :auth_client)
    ladders = AggRager.SC2.sync_ladders(client, player)
    Logger.info "#{inspect ladders}"

    render(conn, "index.html", [
      user: Coherence.current_user(conn),
      ladders: ladders
      ])
  end

  def filter_matches(matches, conn, %{"filter" => filter}) do 
    matches
    |> Enum.filter(&(&1.type == filter))
  end

  def filter_matches(matches, conn, params)do
    matches
  end

end
