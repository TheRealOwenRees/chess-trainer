defmodule ChessTrainerWeb.Chess.Endgame.Tablebase.Move do
  @moduledoc """
  Moves associated with the tablebase
  """

  @type result :: ChessTrainerWeb.Chess.Endgame.Tablebase.result()

  @type t :: %__MODULE__{
          category: result,
          checkmate: boolean(),
          conversion: boolean(),
          dtc: integer() | nil,
          dtm: integer() | nil,
          dtw: integer() | nil,
          dtz: integer() | nil,
          precise_dtz: integer() | nil,
          san: String.t() | nil,
          stalemate: boolean(),
          uci: String.t() | nil,
          variant_loss: boolean(),
          variant_win: boolean(),
          zeroing: boolean(),
          insufficient_material: boolean()
        }

  defstruct category: nil,
            checkmate: false,
            conversion: false,
            dtc: nil,
            dtm: nil,
            dtw: nil,
            dtz: nil,
            precise_dtz: nil,
            san: nil,
            stalemate: false,
            uci: nil,
            variant_loss: false,
            variant_win: false,
            zeroing: false,
            insufficient_material: false

  def from_map(map) do
    %__MODULE__{
      category: map["category"] |> String.to_existing_atom(),
      checkmate: map["checkmate"],
      conversion: map["conversion"],
      dtc: map["dtc"],
      dtm: map["dtm"],
      dtw: map["dtw"],
      dtz: map["dtz"],
      insufficient_material: map["insufficient_material"],
      precise_dtz: map["precise_dtz"],
      san: map["san"],
      stalemate: map["stalemate"],
      uci: map["uci"],
      variant_loss: map["variant_loss"],
      variant_win: map["variant_win"],
      zeroing: map["zeroing"]
    }
  end
end
