defmodule AggRager.SC2.PlayerSeason do
  use Ecto.Schema
  import Ecto.Changeset
  alias AggRager.SC2.PlayerSeason


  schema "player_seasons" do
    field :season_id, :integer
    field :season_number, :integer
    field :season_year, :integer
    field :stats, :map
    field :total_games, :integer
    field :player_id, :id

    timestamps()
  end

  @doc false
  def changeset(%PlayerSeason{} = player_season, attrs) do
    player_season
    |> cast(attrs, [:season_id, :season_number, :season_year, :total_games, :stats])
    |> validate_required([:season_id, :season_number, :season_year, :total_games, :stats])
  end
end
