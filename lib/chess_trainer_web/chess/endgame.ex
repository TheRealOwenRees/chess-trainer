defmodule ChessTrainerWeb.Chess.Endgame do
  @moduledoc """
  Endgame functions
  """

  alias ChessTrainerWeb.Chess.Endgame.Tablebase
  alias ChessTrainerWeb.Chess.Game

  @spec tablebase_from_fen(String.t()) :: Tablebase.t()
  def tablebase_from_fen(fen), do: Tablebase.tablebase_from_fen(fen)

  @spec check_fen_against_tablebase(Game.t()) :: atom()
  def check_fen_against_tablebase(%Game{
        tablebase: tablebase,
        player_color: player_color,
        active_color: active_color
      }) do
    my_move? = player_color == active_color
    opponent_result = tablebase.category

    # at the moment we can not deal with draw result endgames
    cond do
      !my_move? && opponent_result == :loss -> :continue
      !my_move? && opponent_result != :loss -> :loss
      true -> :continue
    end
  end
end
