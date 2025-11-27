defmodule ChessTrainerWeb.BoardLiveComponent do
  @moduledoc """
  Chess board LiveView component
  """
  use Phoenix.LiveComponent
  import ChessTrainerWeb.SquareComponent
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
              move_from_square={@game.move_from_square}
              myself={@myself}
            />
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end

  def update(%{fen: fen, game_type: game_type}, socket) do
    case Game.game_from_fen(fen, game_type) do
      {:ok, game} ->
        socket = assign(socket, game: game)

        if game.game_state == :loss do
          send(self(), {:game_lost})
        end

        {:ok, socket}

      {:error, reason} ->
        {:ok,
         socket
         |> assign(:game, nil)
         |> put_flash(:error, reason)}
    end
  end

  def handle_event("square-click", %{"file" => file, "rank" => rank, "type" => "move"}, socket) do
    {:noreply,
     assign(socket, game: Game.move_piece_from_to_square(socket.assigns.game, file, rank))}
  end

  def handle_info({:game_lost}, socket) do
    {:noreply, put_flash(socket, :error, "Game is lost")}
  end
end
