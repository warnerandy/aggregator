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
    existing_player = Player
      |> Player.find_by_name(attrs["name"])
      |> Repo.one()
      Logger.info "#{inspect parse_player_response(attrs)}"
    case existing_player do
      nil -> create_player(parse_player_response(attrs))
      _ -> update_player(existing_player, parse_player_response(attrs))
    end
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

end
