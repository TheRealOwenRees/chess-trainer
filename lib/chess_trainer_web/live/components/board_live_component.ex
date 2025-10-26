defmodule ChessTrainerWeb.BoardLiveComponent do
  use Phoenix.LiveComponent

  import ChessTrainerWeb.PieceComponent

  def render(assigns) do
    files =
      case assigns.active_color do
        :black -> [:a, :b, :c, :d, :e, :f, :g, :h]
        :white -> Enum.reverse([:a, :b, :c, :d, :e, :f, :g, :h])
      end

    ranks =
      case assigns.active_color do
        :black -> Enum.reverse(1..8)
        :white -> 1..8
      end

    ~H"""
    <div class="w-[388px] m-auto left-0 right-0 mt-6">
      <div class="border border-2 border-zinc-700 grid grid-rows-8 grid-cols-8">
        <%= for rank <- Enum.reverse(ranks) do %>
          <%= for file <- files do %>
            <% square = {file, rank} %>
            <% piece = Map.get(@game.board, square) %>
            <% file_index = Enum.find_index([:a, :b, :c, :d, :e, :f, :g, :h], fn f -> f == file end) %>
            <% rank_index = rank - 1 %>
            <div class={[
              "w-12 h-12 flex items-center justify-center",
              background(file_index, rank_index)
            ]}>
              <.piece piece={piece} class="w-10 h-10" />
            </div>
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end

  def update(%{fen: fen}, socket) do
    game = Chex.Parser.FEN.parse(fen)
    active_color = game.active_color
    {:ok, assign(socket, game: game, active_color: active_color)}
  end

  defp background(file_index, rank_index) when rem(file_index + rank_index, 2) != 0,
    do: "bg-boardwhite"

  defp background(_, _), do: "bg-boardblack"
end
