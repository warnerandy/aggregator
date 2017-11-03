defmodule AggRager.Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def change do
    create table(:players) do
      add :name, :string
      add :display_name, :string
      add :clan_tag, :string
      add :clan, :string
      add :realm, :integer
      add :primary_race, :string
      add :terran_wins, :integer
      add :protoss_wins, :integer
      add :zerg_wins, :integer
      add :highest_solo_rank, :string
      add :highest_team_rank, :string
      add :season_games, :integer
      add :career_games, :integer

      timestamps()
    end

  end
end
