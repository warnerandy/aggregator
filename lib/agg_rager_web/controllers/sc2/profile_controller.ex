defmodule AggRagerWeb.SC2.ProfileController do
  use AggRagerWeb, :controller

  require Logger

  def index(conn, _params) do
  	user_response = get_session(conn, :auth_client)
      |> SC2.get_profile()
    AggRager.SC2.create_update_player(List.first(user_response))

    render(conn, "index.html", [user: Coherence.current_user(conn), profile: user_response])
  end
end
