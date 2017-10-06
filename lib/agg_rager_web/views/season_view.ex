defmodule AggRagerWeb.SeasonView do
  use AggRagerWeb, :view
  alias AggRagerWeb.SeasonView

  def render("index.json", %{seasons: seasons}) do
    %{data: render_many(seasons, SeasonView, "season.json")}
  end

  def render("show.json", %{season: season}) do
    %{data: render_one(season, SeasonView, "season.json")}
  end

  def render("season.json", %{season: season}) do
    %{id: season.id,
      year: season.year,
      sesason_number: season.sesason_number,
      start: season.start,
      end: season.end}
  end
end
