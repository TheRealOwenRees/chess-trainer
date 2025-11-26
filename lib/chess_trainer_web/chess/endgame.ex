defmodule ChessTrainerWeb.Chess.Endgame do
  @moduledoc """
  Endgame functions
  """

  alias ChessTrainerWeb.Chess.Endgame.Tablebase

  # todo check cache/ets first then check lichess api
  # do that in Tablebase.tablebase_from_fen(fen) to keep it abstracted
  def tablebase_from_fen(fen), do: Tablebase.tablebase_from_fen(fen)

  @spec check_move_against_tablebase(String.t(), String.t()) :: term()
  def check_move_against_tablebase(uci, fen) do
    IO.inspect({uci, fen})
    tablebase = Tablebase.tablebase_from_fen(fen)
    IO.inspect(tablebase)
  end
end
