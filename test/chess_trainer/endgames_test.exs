defmodule ChessTrainer.EndgamesTest do
  use ChessTrainer.DataCase

  alias ChessTrainer.Endgames

  describe "endgames" do
    alias ChessTrainer.Endgames.Endgame

    import ChessTrainer.EndgamesFixtures

    @invalid_attrs %{message: nil, result: nil, key: nil, fen: nil, notes: nil}

    test "list_endgames/0 returns all endgames" do
      endgame = endgame_fixture()
      assert Endgames.list_endgames() == [endgame]
    end

    test "get_endgame!/1 returns the endgame with given id" do
      endgame = endgame_fixture()
      assert Endgames.get_endgame!(endgame.id) == endgame
    end

    test "create_endgame/1 with valid data creates a endgame" do
      valid_attrs = %{message: "some message", result: "some result", key: "some key", fen: "some fen", notes: "some notes"}

      assert {:ok, %Endgame{} = endgame} = Endgames.create_endgame(valid_attrs)
      assert endgame.message == "some message"
      assert endgame.result == "some result"
      assert endgame.key == "some key"
      assert endgame.fen == "some fen"
      assert endgame.notes == "some notes"
    end

    test "create_endgame/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Endgames.create_endgame(@invalid_attrs)
    end

    test "update_endgame/2 with valid data updates the endgame" do
      endgame = endgame_fixture()
      update_attrs = %{message: "some updated message", result: "some updated result", key: "some updated key", fen: "some updated fen", notes: "some updated notes"}

      assert {:ok, %Endgame{} = endgame} = Endgames.update_endgame(endgame, update_attrs)
      assert endgame.message == "some updated message"
      assert endgame.result == "some updated result"
      assert endgame.key == "some updated key"
      assert endgame.fen == "some updated fen"
      assert endgame.notes == "some updated notes"
    end

    test "update_endgame/2 with invalid data returns error changeset" do
      endgame = endgame_fixture()
      assert {:error, %Ecto.Changeset{}} = Endgames.update_endgame(endgame, @invalid_attrs)
      assert endgame == Endgames.get_endgame!(endgame.id)
    end

    test "delete_endgame/1 deletes the endgame" do
      endgame = endgame_fixture()
      assert {:ok, %Endgame{}} = Endgames.delete_endgame(endgame)
      assert_raise Ecto.NoResultsError, fn -> Endgames.get_endgame!(endgame.id) end
    end

    test "change_endgame/1 returns a endgame changeset" do
      endgame = endgame_fixture()
      assert %Ecto.Changeset{} = Endgames.change_endgame(endgame)
    end
  end
end
