defmodule AggRagerWeb.SeasonController do
  use AggRagerWeb, :controller

  alias AggRager.SC2
  alias AggRager.SC2.Season

  action_fallback AggRagerWeb.FallbackController

  def index(conn, _params) do
    seasons = SC2.list_seasons()
    render(conn, "index.json", seasons: seasons)
  end

  def create(conn, %{"season" => season_params}) do
    with {:ok, %Season{} = season} <- SC2.create_season(season_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", season_path(conn, :show, season))
      |> render("show.json", season: season)
    end
  end

  def show(conn, %{"id" => id}) do
    season = SC2.get_season!(id)
    render(conn, "show.json", season: season)
  end

  def update(conn, %{"id" => id, "season" => season_params}) do
    season = SC2.get_season!(id)

    with {:ok, %Season{} = season} <- SC2.update_season(season, season_params) do
      render(conn, "show.json", season: season)
    end
  end

  def delete(conn, %{"id" => id}) do
    season = SC2.get_season!(id)
    with {:ok, %Season{}} <- SC2.delete_season(season) do
      send_resp(conn, :no_content, "")
    end
  end
end
