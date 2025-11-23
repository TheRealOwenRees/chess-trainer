defmodule ChessTrainerWeb.BoardLiveComponent do
  use Phoenix.LiveComponent

  import ChessTrainerWeb.PieceComponent

  # TODO abstract Chex away. Create a file such as chess.ex and expose the functions I need - move, game

  def update(%{fen: fen}, socket) do
    # TODO return error if not :ok
    {:ok, game} = Chex.Parser.FEN.parse(fen)

    {:ok,
     assign(socket,
       game: game,
       orientation: board_orientation(game, socket.assigns[:orientation])
     )}
  end

  def handle_event("square-click", %{"file" => f, "rank" => r, "type" => "move"}, socket) do
    # TODO make whole square and move check into composable functions
    file = String.to_existing_atom(f)
    rank = String.to_integer(r)
    board = socket.assigns.game.board
    active_color = socket.assigns.game.active_color
    square_san = f <> r

    socket =
      case socket.assigns[:move_from_square] do
        nil ->
          # No from-square selected yet — try to select a valid piece
          case is_valid_piece_selected({file, rank}, board, active_color) do
            {:ok, _, _, _} ->
              assign(socket, move_from_square: {file, rank})

            _ ->
              assign(socket, move_from_square: nil, move_to_square: nil)
          end

        from_square ->
          # TODO use this to check move validity
          valid_move = valid_move?(socket.assigns.game, from_square, {file, rank})
          IO.inspect(valid_move, label: "valid move?")

          # From-square already selected — this is the destination
          move_san = "#{elem(from_square, 0)}#{elem(from_square, 1)}" <> square_san

          case Chex.Game.move(socket.assigns.game, move_san) do
            {:ok, new_game} ->
              socket
              |> assign(game: new_game)
              |> assign(move_from_square: nil, move_to_square: nil)

            {:error, _reason} ->
              assign(socket, move_from_square: nil, move_to_square: nil)
          end
      end

    {:noreply, socket}
  end

  def render(assigns) do
    files_list = [:a, :b, :c, :d, :e, :f, :g, :h]

    files =
      case assigns.orientation do
        :white -> files_list
        :black -> Enum.reverse(files_list)
      end

    ranks =
      case assigns.orientation do
        :white -> Enum.reverse(1..8)
        :black -> 1..8
      end

    ~H"""
    <div class="w-[388px] m-auto left-0 right-0 mt-6">
      <div class="border border-2 border-zinc-700 grid grid-rows-8 grid-cols-8">
        <%= for rank <- ranks do %>
          <%= for file <- files do %>
            <% square = {file, rank} %>
            <% piece = Map.get(@game.board, square) %>
            <.square
              file={file}
              rank={rank}
              piece={piece}
              files_list={files_list}
              myself={@myself}
            />
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end

  attr :file, :atom, required: true
  attr :rank, :integer, required: true
  attr :piece, :any, default: nil
  attr :files_list, :list, required: true
  attr :myself, :any, required: true

  def square(assigns) do
    ~H"""
    <div
      class={[
        "w-12 h-12 flex items-center justify-center",
        background(
          Enum.find_index(assigns.files_list, fn f -> f == assigns.file end),
          assigns.rank - 1
        )
      ]}
      phx-click="square-click"
      phx-value-file={@file}
      phx-value-rank={@rank}
      phx-value-type="move"
      phx-target={@myself}
    >
      <.piece piece={@piece} class="w-10 h-10" />
    </div>
    """
  end

  # TODO write spec - orientation is either nil or :white or :black, game is ??
  defp board_orientation(game, orientation) when is_nil(orientation), do: game.active_color
  defp board_orientation(_game, orientation), do: orientation

  defp is_valid_piece_selected({file, rank}, board, active_color) do
    case Map.get(board, {file, rank}) do
      {piece, color, {file, rank}} when color == active_color -> {:ok, piece, color, {file, rank}}
      _ -> {:error, nil}
    end
  end

  defp valid_move?(game, move_from_square, move_to_square) do
    Chex.possible_moves(game, move_from_square)
    |> Enum.member?(move_to_square)
  end

  defp background(file_idx, rank_idx) when rem(file_idx + rank_idx, 2) != 0, do: "bg-boardwhite"
  defp background(_, _), do: "bg-boardblack"
end
