defmodule ChessTrainerWeb.EndgameLive.Index do
  use ChessTrainerWeb, :live_view

  alias ChessTrainer.Endgames

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Endgames
        <:actions>
          <.button variant="primary" navigate={~p"/endgames/new"}>
            <.icon name="hero-plus" /> New Endgame
          </.button>
        </:actions>
      </.header>

      <.table
        id="endgames"
        rows={@streams.endgames}
        row_click={fn {_id, endgame} -> JS.navigate(~p"/endgames/#{endgame}") end}
      >
        <:col :let={{_id, endgame}} label="Fen">{endgame.fen}</:col>
        <:col :let={{_id, endgame}} label="Key">{endgame.key}</:col>
        <:col :let={{_id, endgame}} label="Message">{endgame.message}</:col>
        <:col :let={{_id, endgame}} label="Notes">{endgame.notes}</:col>
        <:col :let={{_id, endgame}} label="Result">{endgame.result}</:col>
        <:action :let={{_id, endgame}}>
          <div class="sr-only">
            <.link navigate={~p"/endgames/#{endgame}"}>Show</.link>
          </div>
          <.link navigate={~p"/endgames/#{endgame}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, endgame}}>
          <.link
            phx-click={JS.push("delete", value: %{id: endgame.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Endgames")
     |> stream(:endgames, list_endgames())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    endgame = Endgames.get_endgame!(id)
    {:ok, _} = Endgames.delete_endgame(endgame)

    {:noreply, stream_delete(socket, :endgames, endgame)}
  end

  defp list_endgames() do
    Endgames.list_endgames()
  end
end
