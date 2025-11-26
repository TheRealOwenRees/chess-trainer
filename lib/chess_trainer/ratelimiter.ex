defmodule ChessTrainer.Ratelimiter do
  @moduledoc """
  Ratelimiters
  """

  def create() do
    :ets.new(:lichess_cooldown, [:named_table, :public, :set])
  end
end
