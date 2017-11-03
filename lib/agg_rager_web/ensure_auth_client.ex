defmodule AggRagerWeb.EnsureAuthClient do
  import Plug.Conn
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]
  require Logger

  def init(options) do
    # initialize options

    options
  end

  def call(conn, _opts) do
    auth_client = conn
    |> get_session(:auth_client)
    
    # Logger.debug "session auth client exists: #{!is_nil(auth_client)}"
    # Logger.debug "#{inspect fetch_session(conn)}"
    
    case auth_client do
      x when is_nil(x) -> conn |> redirect(to: '/auth/battle_net') |> halt()
      _ -> conn
    end
  end
end