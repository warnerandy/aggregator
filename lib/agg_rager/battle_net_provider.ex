defmodule CoherenceAssent.Strategy.BattleNet do
  alias CoherenceAssent.Strategy.Helpers
  alias CoherenceAssent.Strategies.OAuth2, as: OAuth2Helper

  require CoherenceAssent

  use AggRagerWeb, :controller

  require Logger

  def authorize_url(conn: conn, config: config) do
    config = config |> set_config |> process_custom
    conn = conn |> put_req_header("accept","application/json")
    OAuth2Helper.authorize_url(conn: conn, config: config)
  end

  def callback(conn: conn, config: config, params: params) do
    config = config |> set_config |> process_custom
    params = params |> process_custom

    client = config
             |> OAuth2.Client.new()
             |> OAuth2.Client.put_header("accept", "application/json")

    {:ok, %{conn: conn, client: client}}
    |> OAuth2Helper.check_conn(params)
    |> OAuth2Helper.get_access_token(params)
    |> OAuth2Helper.get_user(config)
    |> normalize
  end

  defp set_config(config) do
    [
      site: "https://us.api.battle.net",
      authorize_url: "https://us.battle.net/oauth/authorize",
      token_url: "https://us.battle.net/oauth/token",
      token_method: :get,
      user_url: "https://us.api.battle.net/profile/user",
      redirect_uri: config[:custom_redirect_uri],
      authorization_params: [scope: "sc2.profile"]
    ]
    |> Keyword.merge(config)
    |> Keyword.put(:strategy, OAuth2.Strategy.AuthCode)
  end

  defp process_custom(config) when is_map(config) do
    provider = case config[:provider] do
      p when is_nil(p) -> "battle_net"
      p -> p
    end

    custom_config = CoherenceAssent.config(provider)

    case Keyword.has_key?(custom_config, :custom_redirect_uri) do
      true ->
        Map.put(config, "redirect_uri", custom_config[:custom_redirect_uri])
      _ ->
        config
    end
  end

  defp process_custom(config) do
    provider = case config[:provider] do
      p when is_nil(p) -> "battle_net"
      p -> p
    end

    custom_config = CoherenceAssent.config(provider)

    case Keyword.has_key?(custom_config, :custom_redirect_uri) do
      true ->
        Keyword.put(config, :redirect_uri, custom_config[:custom_redirect_uri])
      _ ->
        config
    end
  end


  defp normalize({:ok, %{conn: conn, client: client, user: user}}) do
    user = %{"uid"        => Integer.to_string(user["id"]),
             "name"       => user["battletag"]}
           |> Helpers.prune
    conn = conn |> put_session(:auth_client, client)
    {:ok, %{conn: conn, client: client, user: user}}
  end
  defp normalize({:error, _} = error), do: error
end