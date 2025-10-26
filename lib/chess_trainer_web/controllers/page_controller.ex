defmodule ChessTrainerWeb.PageController do
  use ChessTrainerWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
