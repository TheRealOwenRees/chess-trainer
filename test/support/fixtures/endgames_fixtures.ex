defmodule ChessTrainer.EndgamesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ChessTrainer.Endgames` context.
  """

  @doc """
  Generate a unique endgame fen.
  """
  def unique_endgame_fen, do: "some fen#{System.unique_integer([:positive])}"

  @doc """
  Generate a endgame.
  """
  def endgame_fixture(attrs \\ %{}) do
    {:ok, endgame} =
      attrs
      |> Enum.into(%{
        fen: unique_endgame_fen(),
        key: "some key",
        message: "some message",
        notes: "some notes",
        result: "some result"
      })
      |> ChessTrainer.Endgames.create_endgame()

    endgame
  end
end
