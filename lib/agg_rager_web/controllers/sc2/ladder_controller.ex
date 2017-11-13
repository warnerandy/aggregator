defmodule AggRagerWeb.SC2.LadderController do
  use AggRagerWeb, :controller

  require Logger

  def index(conn, params) do
    player = get_session(conn, :player)
    client = get_session(conn, :auth_client)
    ladders = AggRager.SC2.sync_ladders(client, player)
    # 33 = current season 201 = lov 1v1 0 = random
    leagues = SC2.get_all_leagues(client, 33, 201, 0)
    |> SC2.get_all_league_ranges()
    
    

    render(conn, "index.html", [
      user: Coherence.current_user(conn),
      ladders: ladders,
      leagues: leagues
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
