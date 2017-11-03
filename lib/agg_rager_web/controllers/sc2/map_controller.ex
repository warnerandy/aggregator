defmodule AggRagerWeb.SC2.MapController do
  use AggRagerWeb, :controller

  require Logger

  def index(conn, _params) do
  	user_response = get_session(conn, :auth_client)
      |> SC2.get_profile()

    api_match_response = get_session(conn, :auth_client)
      |> SC2.get_match_history(user_response)
      |> Enum.map(fn (match) -> Map.replace(match, "date", convert_date(match["date"])) end)

    match_stats = SC2.get_match_stats(api_match_response)

    recent_record = SC2.get_recent_record(api_match_response)

    render(conn, "index.html", [user: Coherence.current_user(conn), map_stats: match_stats, history: api_match_response, record: recent_record])
  end

  defp convert_date(unix_date) do
    case DateTime.from_unix(unix_date) do
      {:ok, date} ->
        DateTime.to_string(date)
    end
  end

end
