defmodule AggRagerWeb.EnsurePlayer do
  import Plug.Conn

  def init(options) do
    # initialize options
  end

  def call(conn, _opts) do
    case conn |> get_session(:player) do
      player when is_nil(player) -> 
        user_response = get_session(conn, :auth_client)
          |> SC2.get_profile()
        conn |> put_session(:player, AggRager.SC2.create_update_player(List.first(user_response)))
      _ -> conn
    end
  end
end