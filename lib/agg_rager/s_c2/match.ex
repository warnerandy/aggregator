defmodule AggRager.SC2.Match do
  use Ecto.Schema
  import Ecto.Changeset
  alias AggRager.SC2.Match


  schema "matches" do
    field :date, :integer
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
    |> cast(attrs, [:map, :type, :decision, :date])
    |> validate_required([:map, :type, :decision, :date])
  end
end
