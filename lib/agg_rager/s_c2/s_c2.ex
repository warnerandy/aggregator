defmodule AggRager.SC2 do
  @moduledoc """
  The SC2 context.
  """

  require Logger

  import Ecto.Query, warn: false
  alias AggRager.Repo

  alias AggRager.SC2.Season
  alias AggRager.SC2.Player
  alias AggRager.SC2.Match
  alias AggRager.SC2.PlayerSeason
  alias AggRager.SC2.League
  alias AggRager.SC2.Team
  alias AggRager.SC2.TeamPlayer

  @doc """
  Returns the list of seasons.

  ## Examples

      iex> list_seasons()
      [%Season{}, ...]

  """
  def list_seasons do
    Repo.all(Season)
  end

  @doc """
  Gets a single season.

  Raises `Ecto.NoResultsError` if the Season does not exist.

  ## Examples

      iex> get_season!(123)
      %Season{}

      iex> get_season!(456)
      ** (Ecto.NoResultsError)

  """
  def get_season!(id), do: Repo.get!(Season, id)

  @doc """
  Creates a season.

  ## Examples

      iex> create_season(%{field: value})
      {:ok, %Season{}}

      iex> create_season(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_season(attrs \\ %{}) do
    %Season{}
    |> Season.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a season.

  ## Examples

      iex> update_season(season, %{field: new_value})
      {:ok, %Season{}}

      iex> update_season(season, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_season(%Season{} = season, attrs) do
    season
    |> Season.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Season.

  ## Examples

      iex> delete_season(season)
      {:ok, %Season{}}

      iex> delete_season(season)
      {:error, %Ecto.Changeset{}}

  """
  def delete_season(%Season{} = season) do
    Repo.delete(season)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking season changes.

  ## Examples

      iex> change_season(season)
      %Ecto.Changeset{source: %Season{}}

  """
  def change_season(%Season{} = season) do
    Season.changeset(season, %{})
  end

  ###### PLAYER Methods

  def get_player!(id), do: Repo.get!(Player, id)
  def get_player_by_name!(name), do: Repo.one!(Player.find_by_name(name))

  def create_player(attrs \\ %{}) do
    %Player{}
    |> Player.changeset(attrs)
    |> Repo.insert()
  end

  def update_player(%Player{} = player, attrs) do
    player
    |> Player.changeset(attrs)
    |> Repo.update!()
  end

  def change_player(%Player{} = player) do
    Player.changeset(player, %{})
  end

  def delete_player(%Player{} = player) do
    Repo.delete(player)
  end

  def create_update_player(attrs) do
    existing_player = get_player_by_name!(attrs["name"])
    case existing_player do
      nil -> create_player(parse_player_response(attrs))
      _ -> update_player(existing_player, parse_player_response(attrs))
    end
    get_player_by_name!(attrs["name"])
  end

  def parse_player_response(p) do
    Map.new(
      [{:career_games, p["career"]["careerTotalGames"]},
      {:clan, p["clanName"]},
      {:clan_tag, p["clanTag"]},
      {:display_name, p["displayName"]},
      {:highest_solo_rank, p["career"]["highest1v1Rank"]},
      {:highest_team_rank, p["career"]["highestTeamRank"]},
      {:name, p["name"]},
      {:primary_race, p["career"]["primaryRace"]},
      {:protoss_wins, p["career"]["protossWins"]},
      {:realm, p["realm"]},
      {:season_games, p["career"]["seasonTotalGames"]},
      {:terran_wins, p["career"]["terranWins"]},
      {:zerg_wins, p["career"]["zergWins"]},
      {:player_id, Integer.to_string(p["id"])}])
  end

  def sync_matches(auth_client, player) do
    last_game_date = Match.find_last_game_for_player(Match, player) |> Repo.one()
    matches = SC2.get_match_history(auth_client, player)
      |> Enum.filter(fn (match) ->
        case last_game_date do
          nil -> true
          date -> DateTime.compare(DateTime.from_unix!(Map.get(match, "date")), elem(last_game_date,0)) == :gt
        end

      end)
      |> Enum.map(fn (match) -> 
        m = Map.replace(match, "date", convert_date(match["date"]))
        |> Map.put("player_id", Map.get(player, :id))
        Match.changeset(%Match{}, m)
      end)
    Enum.each(matches, &(Repo.insert(&1)))
    get_matches_for_player(player)
  end

  defp convert_date(unix_date) do
    case DateTime.from_unix(unix_date) do
      {:ok, date} ->
        DateTime.to_string(date)
    end
  end

  def get_matches_for_player(player) do 
    Repo.all(Match.find_by_player(Match, player))
    |> Enum.sort(&(DateTime.compare(&1.date, &2.date) == :gt))
  end

  def sync_ladders(auth_client, player) do
    SC2.get_ladders(auth_client, player)
    |> Enum.filter(&(Enum.count(&1["ladder"]) > 0))
    |> Enum.map(&(List.first(&1["ladder"])))
    |> Enum.map(fn(ladder) -> SC2.get_ladder(auth_client, ladder["ladderId"]) end)
    |> Enum.map(fn(ladder) -> %{teams: Enum.map(ladder["team"], &(Team.normalize_team(&1))), league: ladder["league"]["league_key"]} end)
    # |> List.flatten()
    # |> Enum.map(fn(ladder))
  end

  def get_my_teams(auth_client, player) do
    sync_ladders(auth_client, player)
    |> Enum.map(fn (ladder) ->
      team = List.first(Enum.filter(ladder.teams, fn (team) ->
          Enum.any?(team.members, fn (member) ->
            Integer.to_string(member.id) == player.player_id
          end)
        end))
      create_or_update_team(team)
      %{
        team: team,
        league: ladder.league
      }
    end)
  end

  def create_or_update_team(team) do
    team_resp = Repo.one(Team.find_by_bnet_id(team))
    case (team_resp) do
      nil ->
        create_team(team)
      t ->
        update_team(t, team)
    end
  end

  def create_team(attrs) do
    %Team{}
    |> Team.changeset(attrs)
    |> Repo.insert!()
  end

  def update_team(%Team{} = team, attrs) do
    team
    |> Team.changeset(attrs)
    |> Repo.update!()
  end

  def get_league_data(auth_client, league) do
    leagues = Repo.all(League.load_all(league))
    fetch_leagues = Enum.count(leagues) == 0 or Date.compare(DateTime.to_date(List.first(leagues).date), Date.utc_today) != :eq
    l = case fetch_leagues do
      true -> load_and_save_leagues(auth_client, league)
      _ -> leagues
    end
    Enum.group_by(l, &(Map.get(&1,:league_id)), &(&1))
  end

  def load_and_save_leagues(auth_client, league) do
    leagues = SC2.get_all_leagues(auth_client, league["season_id"], league["queue_id"], league["team_type"])
    |> SC2.get_all_league_ranges()
    |> Enum.each(fn(l) ->
      Enum.each(l, fn (sub) ->
        %League{}
        |> League.changeset(
          %{
            league_id: sub.league_id,
            queue_id: sub.queue_id,
            season_id: sub.season_id,
            team_type: sub.team_type,
            date: DateTime.utc_now(),
            min_rating: sub.min_rating,
            max_rating: sub.max_rating,
            sub_league_id: sub.id
          })
        |> Repo.insert()
      end)
    end)
    Repo.all(League.load_all(league))
  end

end
