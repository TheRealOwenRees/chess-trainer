defmodule ChessTrainerWeb.EndgameLive.Show do
  use ChessTrainerWeb, :live_view

  alias ChessTrainer.Endgames

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Endgame {@endgame.id}
        <:subtitle>This is a endgame record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/endgames"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/endgames/#{@endgame}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit endgame
          </.button>
        </:actions>
      </.header>

      <.live_component module={ChessTrainerWeb.BoardLiveComponent} id="board" fen={@endgame.fen} />

      <.list>
        <:item title="Fen">{@endgame.fen}</:item>
        <:item title="Key">{@endgame.key}</:item>
        <:item title="Message">{@endgame.message}</:item>
        <:item title="Notes">{@endgame.notes}</:item>
        <:item title="Result">{@endgame.result}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Endgame")
     |> assign(:endgame, Endgames.get_endgame!(id))}
  end
end
