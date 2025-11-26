defmodule ChessTrainerWeb.Chess.Endgame do
  @moduledoc """
  Endgame functions
  """

  alias ChessTrainerWeb.Chess.Endgame.Tablebase

  def tablebase_from_fen(fen), do: Tablebase.tablebase_from_fen(fen)

  @spec check_move_against_tablebase(Tablebase.t(), String.t()) :: term()
  def check_move_against_tablebase(tablebase, uci) do
    tablebase.moves
    |> Enum.find(fn move -> move.uci == uci end)
    |> IO.inspect(label: "Matched move")
  end
end
