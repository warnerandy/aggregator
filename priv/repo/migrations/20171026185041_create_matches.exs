defmodule AggRager.Repo.Migrations.CreateMatches do
  use Ecto.Migration

  def change do
    create table(:matches) do
      add :map, :string
      add :type, :string
      add :decision, :string
      add :date, :integer
      add :player_id, references(:players, on_delete: :nothing)
      add :opponent_id, references(:players, on_delete: :nothing)

      timestamps()
    end

    create index(:matches, [:player_id])
    create index(:matches, [:opponent_id])
  end
end
