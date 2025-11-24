defmodule ChessTrainerWeb.BoardLiveComponent do
  use Phoenix.LiveComponent

  import ChessTrainerWeb.PieceComponent

  alias ChessTrainerWeb.Chess.Game

  def render(assigns) do
    files_list = [:a, :b, :c, :d, :e, :f, :g, :h]

    assigns =
      assigns
      |> assign(:files_list, files_list)
      |> assign(
        :files,
        case assigns.game.orientation do
          :white -> files_list
          :black -> Enum.reverse(files_list)
        end
      )
      |> assign(
        :ranks,
        case assigns.game.orientation do
          :white -> Enum.reverse(1..8)
          :black -> 1..8
        end
      )

    ~H"""
    <div class="w-[388px] m-auto left-0 right-0 mt-6">
      <div class="border border-2 border-zinc-700 grid grid-rows-8 grid-cols-8">
        <%= for rank <- @ranks do %>
          <%= for file <- @files do %>
            <% square = {file, rank} %>
            <% piece = Map.get(@game.board, square) %>
            <.square
              file={file}
              rank={rank}
              piece={piece}
              files_list={@files_list}
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

  def update(%{fen: fen}, socket) do
    case Game.game_from_fen(fen) do
      {:ok, game} -> {:ok, assign(socket, game: game)}
      {:error, reason} -> {:error, socket} |> put_flash(socket, reason)
    end
  end

  def handle_event("square-click", %{"file" => file, "rank" => rank, "type" => "move"}, socket) do
    {:noreply,
     assign(socket, game: Game.move_piece_from_to_square(socket.assigns.game, file, rank))}
  end

  defp background(file_idx, rank_idx) when rem(file_idx + rank_idx, 2) != 0, do: "bg-boardwhite"
  defp background(_, _), do: "bg-boardblack"
end
