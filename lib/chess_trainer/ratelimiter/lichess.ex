defmodule ChessTrainer.Ratelimiter.Lichess do
  @moduledoc """
  Global rate limiter for 429 response codes from the Lichess API
  """

  @cooldown_seconds 60

  def create do
    :ets.new(:lichess_cooldown, [:named_table, :public, :set])
  end

  def add_cooldown do
    try do
      insert_cooldown()
    rescue
      ArgumentError ->
        create_and_insert_cooldown()
    end
  end

  def reset_cooldown, do: :ets.insert(:lichess_cooldown, {:until, nil})

  def check_cooldown do
    current_ms = System.system_time(:millisecond)

    try do
      case :ets.lookup(:lichess_cooldown, :until) do
        [] ->
          insert_cooldown()

        [{:until, nil}] ->
          {:ok, 0}

        [{:until, until_ms}] ->
          if current_ms >= until_ms do
            reset_cooldown()
            {:ok, 0}
          else
            {:cooldown, until_ms - current_ms}
          end
      end
    rescue
      ArgumentError -> create_and_insert_cooldown()
    end
  end

  defp insert_cooldown do
    :ets.insert(
      :lichess_cooldown,
      {:until,
       System.system_time(:millisecond)
       |> then(&(&1 + @cooldown_seconds * 1000))}
    )
  end

  defp create_and_insert_cooldown do
    create()
    insert_cooldown()
  end
end
