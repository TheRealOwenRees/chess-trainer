defmodule ChessTrainerWeb.PieceComponent do
  use Phoenix.Component

  attr :piece, :any, required: true
  attr :class, :string, default: ""

  def piece(assigns) do
    assigns = assign(assigns, :path, piece_path(assigns.piece))

    ~H"""
    <%= if @path do %>
      <img src={@path} class={@class} />
    <% end %>
    """
  end

  defp piece_path({:king, :white, _square}), do: "/images/pieces/white/king.svg"
  defp piece_path({:queen, :white, _square}), do: "/images/pieces/white/queen.svg"
  defp piece_path({:rook, :white, _square}), do: "/images/pieces/white/rook.svg"
  defp piece_path({:bishop, :white, _square}), do: "/images/pieces/white/bishop.svg"
  defp piece_path({:knight, :white, _square}), do: "/images/pieces/white/knight.svg"
  defp piece_path({:pawn, :white, _square}), do: "/images/pieces/white/pawn.svg"
  defp piece_path({:king, :black, _square}), do: "/images/pieces/black/king.svg"
  defp piece_path({:queen, :black, _square}), do: "/images/pieces/black/queen.svg"
  defp piece_path({:rook, :black, _square}), do: "/images/pieces/black/rook.svg"
  defp piece_path({:bishop, :black, _square}), do: "/images/pieces/black/bishop.svg"
  defp piece_path({:knight, :black, _square}), do: "/images/pieces/black/knight.svg"
  defp piece_path({:pawn, :black, _square}), do: "/images/pieces/black/pawn.svg"
  defp piece_path(_), do: nil
end
