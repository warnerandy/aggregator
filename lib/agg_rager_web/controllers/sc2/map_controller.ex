defmodule AggRagerWeb.SC2.MapController do
  use AggRagerWeb, :controller

  require Logger

  def index(conn, _params) do
    player = get_session(conn, :player)
    client = get_session(conn, :auth_client)
    matches = AggRager.SC2.sync_matches(client, player)

    match_stats = SC2.get_match_stats(matches)

    recent_record = SC2.get_recent_record(matches)

    render(conn, "index.html", [user: Coherence.current_user(conn), map_stats: match_stats, history: matches |> Enum.map(&(Map.from_struct(&1))), record: recent_record])
  end

end
