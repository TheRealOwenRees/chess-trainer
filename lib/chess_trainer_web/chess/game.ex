defmodule ChessTrainerWeb.Chess.Game do
  @moduledoc """
  Game related functions
  """
  alias ChessTrainerWeb.Chess.Endgame

  @type game_type :: :endgame
  @type square :: {atom(), pos_integer()}
  @type move :: {square, square}
  @type orientation :: :white | :black

  @type t :: %__MODULE__{
          player_color: orientation,
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
          move_to_square: square,
          game_type: game_type,
          fen: String.t(),
          tablebase: term()
        }

  defstruct board: %{},
            player_color: nil,
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
            move_to_square: nil,
            game_type: nil,
            fen: nil,
            tablebase: nil

  @doc """
  Return a game struct from a valid FEN string
  """
  @spec game_from_fen(String.t(), game_type()) :: {:ok, t()} | {:error, atom()}
  def game_from_fen(fen, game_type) do
    try do
      {:ok, %Chex.Game{} = chex_game} = Chex.Parser.FEN.parse(fen)

      game = %__MODULE__{
        player_color: chex_game.active_color,
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
        orientation: nil,
        game_type: game_type,
        fen: fen,
        tablebase:
          if game_type === :endgame do
            Endgame.tablebase_from_fen(fen)
          else
            nil
          end
      }

      {:ok, %{game | orientation: board_orientation(game, game.orientation)}}
    rescue
      MatchError -> {:error, :invalid_fen}
    end
  end

  @doc """
  Update game state with piece movement from and to a square, via handle_event.
  """
  @spec move_piece_from_to_square(t(), String.t(), String.t()) :: t()
  def move_piece_from_to_square(game, file, rank) do
    file_atom = String.to_existing_atom(file)
    rank_integer = String.to_integer(rank)

    case game.move_from_square do
      nil ->
        case check_valid_piece_selected({file_atom, rank_integer}, game.board, game.active_color) do
          {:ok, _, _, _} ->
            %{game | move_from_square: {file_atom, rank_integer}}

          _ ->
            %{game | move_from_square: nil, move_to_square: nil}
        end

      _ ->
        case move(game, {game.move_from_square, {file_atom, rank_integer}}) do
          {:ok, new_game} ->
            %{new_game | move_from_square: nil, move_to_square: nil}

          {:error, _reason} ->
            %{game | move_from_square: nil, move_to_square: nil}
        end
    end
  end

  # Abstraction of Chex.Game.move/2 to match our game struct
  @spec move(t(), move) :: {:ok, t()} | {:error, atom()}
  defp move(game, {from, to}) do
    chex_game =
      game
      |> Map.from_struct()
      |> Map.delete(:orientation)
      |> Map.delete(:move_from_square)
      |> Map.delete(:move_to_square)
      |> Map.delete(:game_type)
      |> Map.delete(:fen)
      |> Map.delete(:player_color)
      |> Map.delete(:tablebase)
      |> then(&struct(Chex.Game, &1))

    case Chex.Game.move(chex_game, {from, to}) do
      {:ok, %Chex.Game{} = chex_game} ->
        fen = Chex.Parser.FEN.serialize_board(chex_game.board)

        tablebase =
          if game.game_type === :endgame do
            Endgame.tablebase_from_fen(fen)
          else
            nil
          end

        new_game = %__MODULE__{
          player_color: game.player_color,
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
          orientation: game.orientation,
          move_from_square: nil,
          move_to_square: nil,
          game_type: game.game_type,
          fen: fen,
          tablebase: tablebase
        }

        tablebase_result = Endgame.check_fen_against_tablebase(new_game)
        IO.inspect(tablebase_result)
        # the result of tablebase checks could be :lost or :draw
        # in which case return the new game position but pass :lost / :draw and stop game
        # we will probably need a :continue in the below tuple

        {:ok, new_game}

      {_error, reason} ->
        {:error, reason}
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

  defp check_valid_piece_selected({file, rank}, board, active_color) do
    case Map.get(board, {file, rank}) do
      {piece, color, {file, rank}} when color == active_color -> {:ok, piece, color, {file, rank}}
      _ -> {:error, nil}
    end
  end

  # @spec move_to_uci(square, square) :: String.t()
  # defp move_to_uci(from, to) do
  #   from = "#{elem(from, 0)}#{elem(from, 1)}"
  #   to = "#{elem(to, 0)}#{elem(to, 1)}"
  #   from <> to
  # end
end
