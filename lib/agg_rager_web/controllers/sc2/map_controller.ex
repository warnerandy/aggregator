defmodule AggRagerWeb.SC2.MapController do
  use AggRagerWeb, :controller

  require Logger

  def index(conn, params) do
    player = get_session(conn, :player)
    client = get_session(conn, :auth_client)
    matches = AggRager.SC2.sync_matches(client, player)
    |> filter_matches(conn, params);

    Logger.info "#{inspect matches }"

    match_stats = SC2.get_match_stats(matches)

    recent_record = SC2.get_recent_record(matches)

    render(conn, "index.html", [user: Coherence.current_user(conn), map_stats: match_stats, history: matches |> Enum.map(&(Map.from_struct(&1))), record: recent_record])
  end

  def filter_matches(matches, conn, %{"filter" => filter}) do 
    matches
    |> Enum.filter(&(&1.type == filter))
  end

  def filter_matches(matches, conn, params)do
    matches
  end

end
