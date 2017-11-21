defmodule AggRagerWeb.SC2.LadderController do
  use AggRagerWeb, :controller

  require Logger

  def index(conn, params) do
    player = get_session(conn, :player)
    client = get_session(conn, :auth_client)
    season = SC2.get_current_season(client)
    Logger.info "#{inspect season}"
    Logger.info "#{inspect params}"
    ladders = AggRager.SC2.get_my_teams(client, player)

    leagues = Enum.map(ladders, fn(ladder) ->
      league_data = AggRager.SC2.get_league_data(client, ladder.league)

      min_mmr_leagues = AggRager.SC2.ParseLeagues.get_min_rating_per_league(league_data)
      league_disp = AggRager.SC2.ParseLeagues.get_ladder_league_pct(league_data)
      team_position = AggRager.SC2.ParseLeagues.get_pct_for_rating(league_data, ladder.team.rating)
      %{
        league: ladder.league,
        team: ladder.team,
        league_data: league_data,
        league_placements: league_disp,
        team_position: team_position,
        min_mmr_leagues: min_mmr_leagues,
        team_league: AggRager.SC2.ParseLeagues.get_league_name(ladder.league["league_id"]),
        team_league_type: AggRager.SC2.ParseLeagues.get_league_type(ladder.league["queue_id"])
      }
    end)
  #   |> List.flatten()
  #   |> Enum.group_by(&(Map.get(&1,:league_id)), &(&1))

  #   min_mmr_leagues = Enum.map(leagues, fn(league) ->
  #     min_rating = Enum.filter(elem(league,1), fn(sub) ->
  #       sub.sub_league_id == 2
  #     end)
  #     |>List.first()
  #     |>Map.get(:min_rating)

  #     {get_league_name(elem(league,0)), min_rating}
  #   end)

  #   max_mmr = Enum.filter(leagues, fn(league) ->
  #     elem(league, 0) == 5
  #   end)
  #   |>List.first()
  #   |>elem(1)
  #   |>Enum.filter(fn (sub) ->
  #     sub.sub_league_id == 0
  #   end)
  #   |>List.first()
  #   |>Map.get(:max_rating)

  #   min_mmr = Enum.filter(min_mmr_leagues, fn(league) ->
  #     elem(league, 0) == "bronze"
  #   end)
  #   |> List.first()
  #   |> elem(1)

  #   Logger.info "#{inspect min_mmr}"

  #   range = max_mmr - min_mmr

  #   min_pct_leagues = Enum.map(min_mmr_leagues, fn(league) ->
  #     {elem(league,0), ((elem(league,1) - min_mmr)/range) * 100}
  #   end)

  #   team_pct = Enum.map(ladders, fn(ladder) ->
  #     {get_league_name(ladder.league["league_id"]), ((ladder.team.mmr - min_mmr)/range) * 100}
  #   end)

  # Logger.info "#{inspect Enum.map(leagues, &(&1.team_position))}"

    render(conn, "index.html", [
      user: Coherence.current_user(conn),
      ladders: ladders,
      leagues: leagues,
      # chart_mmr: min_mmr_leagues,
      # chart_pct: min_pct_leagues,
      # team_pct: team_pct
      ])
  end

  def filter_matches(matches, conn, %{"filter" => filter}) do 
    matches
    |> Enum.filter(&(&1.type == filter))
  end

  def filter_matches(matches, conn, params)do
    matches
  end

  def get_league_name(league_id) do
    case (league_id) do
        0 -> "bronze"
        1 -> "silver"
        2 -> "gold"
        3 -> "plat"
        4 -> "diamond"
        5 -> "master"
      end
  end

end
