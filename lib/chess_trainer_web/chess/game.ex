defmodule ChessTrainerWeb.Chess.Game do
  @moduledoc """
  Game related functions
  """

  @type square :: {atom(), integer()} | nil
  @type orientation :: :white | :black | nil

  @type t :: %__MODULE__{
          board: map(),
          active_color: :white | :black,
          castling: list(),
          en_passant: term() | nil,
          moves: list(),
          halfmove_clock: non_neg_integer(),
          fullmove_clock: non_neg_integer(),
          captures: list(),
          check: term() | nil,
          result: term() | nil,
          pgn: String.t() | nil,
          orientation: orientation,
          move_from_square: square,
          move_to_square: square
        }

  defstruct board: %{},
            active_color: nil,
            castling: [],
            en_passant: nil,
            moves: [],
            halfmove_clock: 0,
            fullmove_clock: 0,
            captures: [],
            check: nil,
            result: nil,
            pgn: nil,
            orientation: nil,
            move_from_square: nil,
            move_to_square: nil

  @doc """
  Return a game struct from a valid FEN string
  """
  @spec game_from_fen(String.t()) :: {:ok, t()} | {:error, atom()}
  def game_from_fen(fen) do
    case Chex.Parser.FEN.parse(fen) do
      {:ok, %Chex.Game{} = chex_game} ->
        game = %__MODULE__{
          board: chex_game.board,
          active_color: chex_game.active_color,
          castling: chex_game.castling,
          en_passant: chex_game.en_passant,
          moves: chex_game.moves,
          halfmove_clock: chex_game.halfmove_clock,
          fullmove_clock: chex_game.fullmove_clock,
          captures: chex_game.captures,
          check: chex_game.check,
          result: chex_game.result,
          pgn: chex_game.pgn,
          orientation: nil
        }

        {:ok, %{game | orientation: board_orientation(game, game.orientation)}}

      {_error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Register a move in the game using SAN notation.
  """
  @spec move(t(), String.t()) :: {:ok, t() | {:error, atom()}}
  def move(game, move_san) do
    chex_game =
      game
      |> Map.from_struct()
      |> Map.delete(:orientation)
      |> Map.delete(:move_from_square)
      |> Map.delete(:move_to_square)
      |> then(&struct(Chex.Game, &1))

    case Chex.Game.move(chex_game, move_san) do
      {:ok, %Chex.Game{} = chex_game} ->
        %__MODULE__{
          board: chex_game.board,
          active_color: chex_game.active_color,
          castling: chex_game.castling,
          en_passant: chex_game.en_passant,
          moves: chex_game.moves,
          halfmove_clock: chex_game.halfmove_clock,
          fullmove_clock: chex_game.fullmove_clock,
          captures: chex_game.captures,
          check: chex_game.check,
          result: chex_game.result,
          pgn: chex_game.pgn,
          orientation: game.orientation
        }

      {_error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Update game state with piece movement from and to a square, via handle_event
  """
  @spec move_piece_from_to_square(t(), String.t(), String.t()) :: t()
  def move_piece_from_to_square(game, file, rank) do
    file_atom = String.to_existing_atom(file)
    rank_integer = String.to_integer(rank)
    square_san = file <> rank

    case game.move_from_square do
      nil ->
        case is_valid_piece_selected({file_atom, rank_integer}, game.board, game.active_color) do
          {:ok, _, _, _} ->
            %{game | move_from_square: {file_atom, rank_integer}}

          _ ->
            %{game | move_from_square: nil, move_to_square: nil}
        end

      move_from_square ->
        move_san =
          "#{elem(move_from_square, 0)}#{elem(move_from_square, 1)}" <> square_san

        case move(game, move_san) do
          {:ok, new_game} -> %{new_game | move_from_square: nil, move_to_square: nil}
          {:error, _reason} -> %{game | move_from_square: nil, move_to_square: nil}
        end
    end
  end

  @doc """
  Reverse the board orientation. Used for flipping the board.
  """
  @spec flip_orientation(t()) :: t()
  def flip_orientation(%__MODULE__{orientation: :black} = game), do: %{game | orientation: :white}
  def flip_orientation(%__MODULE__{orientation: :white} = game), do: %{game | orientation: :black}
  def flip_orientation(game) when is_nil(game.orientation), do: %{game | orientation: nil}

  @spec board_orientation(t(), orientation()) :: orientation
  defp board_orientation(game, orientation) when is_nil(orientation), do: game.active_color
  defp board_orientation(_game, orientation), do: orientation

  defp is_valid_piece_selected({file, rank}, board, active_color) do
    case Map.get(board, {file, rank}) do
      {piece, color, {file, rank}} when color == active_color -> {:ok, piece, color, {file, rank}}
      _ -> {:error, nil}
    end
  end
end
