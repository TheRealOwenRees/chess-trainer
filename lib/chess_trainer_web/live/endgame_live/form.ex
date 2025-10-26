defmodule ChessTrainerWeb.EndgameLive.Form do
  use ChessTrainerWeb, :live_view

  alias ChessTrainer.Endgames
  alias ChessTrainer.Endgames.Endgame

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage endgame records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="endgame-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:fen]} type="text" label="Fen" />
        <.input field={@form[:key]} type="text" label="Key" />
        <.input field={@form[:message]} type="textarea" label="Message" />
        <.input field={@form[:notes]} type="textarea" label="Notes" />
        <.input field={@form[:result]} type="text" label="Result" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Endgame</.button>
          <.button navigate={return_path(@return_to, @endgame)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    endgame = Endgames.get_endgame!(id)

    socket
    |> assign(:page_title, "Edit Endgame")
    |> assign(:endgame, endgame)
    |> assign(:form, to_form(Endgames.change_endgame(endgame)))
  end

  defp apply_action(socket, :new, _params) do
    endgame = %Endgame{}

    socket
    |> assign(:page_title, "New Endgame")
    |> assign(:endgame, endgame)
    |> assign(:form, to_form(Endgames.change_endgame(endgame)))
  end

  @impl true
  def handle_event("validate", %{"endgame" => endgame_params}, socket) do
    changeset = Endgames.change_endgame(socket.assigns.endgame, endgame_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"endgame" => endgame_params}, socket) do
    save_endgame(socket, socket.assigns.live_action, endgame_params)
  end

  defp save_endgame(socket, :edit, endgame_params) do
    case Endgames.update_endgame(socket.assigns.endgame, endgame_params) do
      {:ok, endgame} ->
        {:noreply,
         socket
         |> put_flash(:info, "Endgame updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, endgame))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_endgame(socket, :new, endgame_params) do
    case Endgames.create_endgame(endgame_params) do
      {:ok, endgame} ->
        {:noreply,
         socket
         |> put_flash(:info, "Endgame created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, endgame))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _endgame), do: ~p"/endgames"
  defp return_path("show", endgame), do: ~p"/endgames/#{endgame}"
end
