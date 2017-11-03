defmodule AggRager.Repo.Migrations.AddPlayerIdToPlayer do
  use Ecto.Migration

  def change do
 	alter table(:players) do
 		add :player_id, :string
 	end
  end
end
