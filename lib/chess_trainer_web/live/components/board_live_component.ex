defmodule ChessTrainerWeb.BoardLiveComponent do
  use Phoenix.LiveComponent

  import ChessTrainerWeb.PieceComponent

  def render(assigns) do
    ~H"""
    <div class="w-[388px] m-auto left-0 right-0 mt-6">
      <div class="border border-2 border-zinc-700 grid grid-rows-8 grid-cols-8">
        <%= for rank_index <- Enum.reverse(0..7) do %>
          <%= for file_index <- 0..7 do %>
            <% file = Enum.at([:a, :b, :c, :d, :e, :f, :g, :h], file_index) %>
            <% rank = rank_index + 1 %>
            <% square = {file, rank} %>
            <% piece = Map.get(@game.board, square) %>
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
    IO.inspect(game.board)
    {:ok, assign(socket, game: game)}
  end

  defp background(file_index, rank_index) when rem(file_index + rank_index, 2) != 0,
    do: "bg-boardwhite"

  defp background(_, _), do: "bg-boardblack"
end
