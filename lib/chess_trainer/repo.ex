defmodule ChessTrainer.Repo do
  use Ecto.Repo,
    otp_app: :chess_trainer,
    adapter: Ecto.Adapters.Postgres
end
