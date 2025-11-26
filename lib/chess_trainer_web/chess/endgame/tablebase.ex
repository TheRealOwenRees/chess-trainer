defmodule ChessTrainerWeb.Chess.Endgame.Tablebase do
  @moduledoc """
  All endgame tablebase related functions.
  """
  alias ChessTrainerWeb.Chess.Endgame.Tablebase.Move
  alias ChessTrainer.Ratelimiter

  @lichess_tablebase_url "http://tablebase.lichess.ovh/standard?fen="

  @type result :: :win | :draw | :loss

  @type t :: %__MODULE__{
          category: result,
          checkmate: boolean(),
          dtc: integer() | nil,
          dtm: integer() | nil,
          dtw: integer() | nil,
          dtz: integer() | nil,
          insufficient_material: boolean(),
          moves: [Move.t()]
        }

  defstruct category: nil,
            checkmate: false,
            dtc: nil,
            dtm: nil,
            dtw: nil,
            dtz: nil,
            insufficient_material: false,
            moves: nil

  @doc """
  Lichess tablebase response from FEN string.
  https://lichess.org/api#tag/tablebase

  FEN must have spaces replaced by underscores to satisfy the Lichess API.
  """
  def tablebase_from_fen(fen) do
    case Ratelimiter.Lichess.check_cooldown() do
      {:cooldown, remaining_ms} -> {:cooldown, remaining_ms}
      {:ok, _} -> tablebase_response(fen)
    end
  end

  # todo check cache/ets first then check lichess api
  defp tablebase_response(fen) do
    response =
      fen
      |> sanitise_fen()
      |> build_request_string()
      |> Req.get()
      |> parse_response()

    case response do
      {:ok, body} -> from_map(body)
      {:error, reason} -> {:error, reason}
    end
  end

  defp from_map(map) do
    %__MODULE__{
      category: map["category"] |> String.to_existing_atom(),
      checkmate: map["checkmate"],
      dtc: map["dtc"],
      dtm: map["dtm"],
      dtw: map["dtw"],
      dtz: map["dtz"],
      insufficient_material: map["insufficient_material"],
      moves: Enum.map(map["moves"], &Move.from_map/1)
    }
  end

  defp parse_response(response) do
    case response do
      # Success
      {:ok, %Req.Response{status: 200, body: body}} ->
        {:ok, body}

      # Client errors
      {:ok, %Req.Response{status: status, body: body}} when status in 400..499 ->
        {:error, {:client_error, status, body}}

      # Rate limiting
      {:ok, %Req.Response{status: 429, body: body}} ->
        Ratelimiter.Lichess.add_cooldown()
        {:error, {:too_many_requests, 429, body}}

      # Server errors
      {:ok, %Req.Response{status: status, body: body}} when status in 500..599 ->
        {:error, {:server_error, status, body}}

      # Catch‑all for other status codes
      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, {:http_error, status, body}}

      # Network / client‑side failure
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp sanitise_fen(fen), do: String.replace(fen, " ", "_")

  defp build_request_string(fen), do: "#{@lichess_tablebase_url}#{fen}"
end
