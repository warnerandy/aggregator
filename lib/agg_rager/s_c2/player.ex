defmodule AggRager.SC2.Player do
  use Ecto.Schema
  import Ecto.Changeset
  alias AggRager.SC2.Player
  import Ecto.Query, only: [from: 2]

  require Logger

  schema "players" do
    field :career_games, :integer
    field :clan, :string
    field :clan_tag, :string
    field :display_name, :string
    field :highest_solo_rank, :string
    field :highest_team_rank, :string
    field :name, :string
    field :primary_race, :string
    field :protoss_wins, :integer
    field :realm, :integer
    field :season_games, :integer
    field :terran_wins, :integer
    field :zerg_wins, :integer
    field :player_id, :string

    timestamps()
  end

  @doc false
  def changeset(%Player{} = player, attrs) do
    player
    |> cast(attrs, [:name, :display_name, :clan_tag, :clan, :realm, :primary_race, :terran_wins, :protoss_wins, :zerg_wins, :highest_solo_rank, :highest_team_rank, :season_games, :career_games, :player_id])
    |> validate_required([:name])
  end

  def find_by_name(query, name) when not is_nil(name) do
    Logger.info "#{name}"
    from p in query, where: p.name == ^name
  end
end
