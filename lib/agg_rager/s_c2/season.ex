defmodule AggRager.SC2.Season do
  use Ecto.Schema
  import Ecto.Changeset
  alias AggRager.SC2.Season


  schema "seasons" do
    field :end, :naive_datetime
    field :sesason_number, :string
    field :start, :naive_datetime
    field :year, :string

    timestamps()
  end

  @doc false
  def changeset(%Season{} = season, attrs) do
    season
    |> cast(attrs, [:year, :sesason_number, :start, :end])
    |> validate_required([:year, :sesason_number, :start, :end])
  end
end
