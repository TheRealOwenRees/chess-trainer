defmodule ChessTrainer.Endgames.Endgame do
  @moduledoc """
  Singular endgame
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "endgames" do
    field :fen, :string
    field :key, :string
    field :message, :string
    field :notes, :string
    field :result, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(endgame, attrs) do
    endgame
    |> cast(attrs, [:fen, :key, :message, :notes, :result])
    |> validate_required([:fen, :key, :message, :notes, :result])
    |> validate_inclusion(:result, ["win", "draw"])
    |> unique_constraint(:fen)
  end
end
