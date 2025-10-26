defmodule ChessTrainer.Repo.Migrations.CreateEndgames do
  use Ecto.Migration

  def change do
    create table(:endgames, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :fen, :string
      add :key, :string
      add :message, :text
      add :notes, :text
      add :result, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:endgames, [:fen])
  end
end
