defmodule AggRager.SC2.Match do
  use Ecto.Schema
  import Ecto.Changeset
  alias AggRager.SC2.Match

  import Ecto.Query, only: [from: 2]

  require Logger

  schema "matches" do
    field :date, :utc_datetime
    field :decision, :string
    field :map, :string
    field :type, :string
    field :player_id, :id
    field :opponent_id, :id

    timestamps()
  end

  @doc false
  def changeset(%Match{} = match, attrs) do
    match
    |> cast(attrs, [:map, :type, :decision, :date, :player_id])
    |> validate_required([:map, :type, :decision, :date])
  end

    def find_by_player(query, player) when not is_nil(player) do
      player_id = Map.get(player, :id)
      from p in query, where: p.player_id == ^player_id
    end

    def find_last_game_for_player(query, player) when not is_nil(player) do
      player_id = Map.get(player, :id)

      from p in query,
      select: {p.date},
      where: p.player_id == ^player_id,
      order_by: [desc: :date],
      limit: 1
    end
end
