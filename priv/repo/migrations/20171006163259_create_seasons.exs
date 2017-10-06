defmodule AggRager.Repo.Migrations.CreateSeasons do
  use Ecto.Migration

  def change do
    create table(:seasons) do
      add :year, :string
      add :sesason_number, :string
      add :start, :naive_datetime
      add :end, :naive_datetime

      timestamps()
    end

  end
end
