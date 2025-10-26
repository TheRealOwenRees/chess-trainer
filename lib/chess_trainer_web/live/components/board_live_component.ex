defmodule ChessTrainerWeb.BoardLiveComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <div class="w-[388px] m-auto left-0 right-0 mt-6">
      <div class="border border-2 border-zinc-700 grid grid-rows-8 grid-cols-8">
        <%= for rank <- Enum.reverse(0..7) do %>
          <%= for file <- 0..7 do %>
            <div class={["w-12 h-12", background(file, rank)]}>
              <!-- You can render pieces here later -->
            </div>
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end

  defp background(file, rank) when rem(file + rank, 2) != 0, do: "bg-boardwhite"
  defp background(_, _), do: "bg-boardblack"
end
