# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ChessTrainer.Repo.insert!(%ChessTrainer.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias ChessTrainer.Repo
alias ChessTrainer.Endgames.Endgame

now = DateTime.utc_now() |> DateTime.truncate(:second)

IO.puts("🌱 Seeding basic endgames into DB...")

Repo.insert_all(Endgame, [
  %{
    id: Ecto.UUID.generate(),
    fen: "8/8/3k4/8/8/3K1R2/8/8 w - - 0 1",
    key: "KRvK",
    message: "Rook vs king endgame",
    notes: "Basic rook endgame",
    result: "win",
    inserted_at: now,
    updated_at: now
  },
  %{
    id: Ecto.UUID.generate(),
    fen: "6k1/5p2/6p1/8/7p/8/6PP/6K1 b - - 0 0",
    key: "KPPPvKPP",
    message: "3 pawns vs 2 pawns",
    notes: "https://www.chessgames.com/perl/chessgame?gid=1017147",
    result: "win",
    inserted_at: now,
    updated_at: now
  }
])

IO.puts("✅ Done seeding endgames.")
