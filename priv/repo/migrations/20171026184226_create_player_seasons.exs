defmodule AggRager.Repo.Migrations.CreatePlayerSeasons do
  use Ecto.Migration

  def change do
    create table(:player_seasons) do
      add :season_id, :integer
      add :season_number, :integer
      add :season_year, :integer
      add :total_games, :integer
      add :stats, :map
      add :player_id, references(:players, on_delete: :nothing)

      timestamps()
    end

    create index(:player_seasons, [:player_id])
  end
end
