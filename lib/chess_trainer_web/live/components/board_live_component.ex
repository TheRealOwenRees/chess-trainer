defmodule ChessTrainerWeb.BoardLiveComponent do
  use Phoenix.LiveComponent

  import ChessTrainerWeb.PieceComponent

  def update(%{fen: fen}, socket) do
    game = Chex.Parser.FEN.parse(fen)

    orientation =
      case socket.assigns[:orientation] do
        nil -> game.active_color
        existing -> existing
      end

    {:ok, assign(socket, game: game, orientation: orientation)}
  end

  def handle_event("square-click", %{"file" => f, "rank" => r, "type" => "move"}, socket) do
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
              assign(socket, move_from_square: square_san)

            _ ->
              assign(socket, move_from_square: nil, move_to_square: nil)
          end

        from_square ->
          # From-square already selected — this is the destination
          move_san = from_square <> square_san

          case Chex.Game.move(socket.assigns.game, move_san) do
            {:ok, new_game} ->
              socket
              |> assign(game: new_game)
              |> assign(move_from_square: nil, move_to_square: nil)

            {:error, _reason} ->
              assign(socket, move_from_square: nil, move_to_square: nil)
          end
      end

    IO.inspect(socket)

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

  # Check that the selected square contains a piece of the player who's turn it is to move
  defp is_valid_piece_selected({file, rank}, board, active_color) do
    case Map.get(board, {file, rank}) do
      {piece, color, {file, rank}} when color == active_color -> {:ok, piece, color, {file, rank}}
      _ -> {:error, nil}
    end
  end

  defp background(file_index, rank_index) when rem(file_index + rank_index, 2) != 0,
    do: "bg-boardwhite"

  defp background(_, _), do: "bg-boardblack"
end
