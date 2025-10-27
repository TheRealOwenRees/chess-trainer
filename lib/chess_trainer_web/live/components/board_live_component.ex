defmodule ChessTrainerWeb.BoardLiveComponent do
  use Phoenix.LiveComponent

  import ChessTrainerWeb.PieceComponent

  def update(%{fen: fen}, socket) do
    game = Chex.Parser.FEN.parse(fen)
    {:ok, assign(socket, game: game)}
  end

  def handle_event("square-click", %{"file" => f, "rank" => r, "type" => "move"}, socket) do
    file = String.to_existing_atom(f)
    rank = String.to_integer(r)
    board = socket.assigns.game.board
    active_color = socket.assigns.game.active_color
    IO.inspect(socket)
    selected_square = is_piece_selected({file, rank}, board, active_color)
    IO.inspect(selected_square)
    {:noreply, socket}
  end

  @doc """
  Check that the selected square contains a piece of the player who's turn it is to move
  """
  defp is_piece_selected({file, rank}, board, active_color) do
    case Map.get(board, {file, rank}) do
      {_piece, color, {file, rank}} when color == active_color -> {:ok, {file, rank}}
      _ -> {:error, nil}
    end
  end

  def render(assigns) do
    files_list = [:a, :b, :c, :d, :e, :f, :g, :h]

    files =
      case assigns.game.active_color do
        :white -> files_list
        :black -> Enum.reverse(files_list)
      end

    ranks =
      case assigns.game.active_color do
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
            <% file_index = Enum.find_index(files_list, fn f -> f == file end) %>
            <% rank_index = rank - 1 %>
            <div
              class={[
                "w-12 h-12 flex items-center justify-center",
                background(file_index, rank_index)
              ]}
              phx-click="square-click"
              phx-value-file={file}
              phx-value-rank={rank}
              phx-value-type="move"
              phx-target={@myself}
            >
              <.piece piece={piece} class="w-10 h-10" />
            </div>
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end

  defp background(file_index, rank_index) when rem(file_index + rank_index, 2) != 0,
    do: "bg-boardwhite"

  defp background(_, _), do: "bg-boardblack"
end
