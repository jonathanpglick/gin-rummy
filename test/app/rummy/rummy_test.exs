defmodule App.RummyTest do
  use App.DataCase

  alias App.Rummy
  alias App.Accounts

  describe "games" do
    alias App.Rummy.Game
    alias App.Rummy.Player

    @valid_attrs %{discard_deck: [], draw_deck: [], name: "some name"}
    @update_attrs %{discard_deck: [], draw_deck: [], name: "some updated name"}
    @invalid_attrs %{discard_deck: nil, draw_deck: nil, name: nil, status: nil}

    def game_fixture(attrs \\ %{}) do
      {:ok, game} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Rummy.create_game()

      game
    end

    def game_with_users_fixture(attrs \\ %{}) do
      game = game_fixture(attrs)
      Rummy.add_player(game, user_fixture(%{name: "Jon"}))
      Rummy.add_player(game, user_fixture(%{name: "Jen"}))
      Rummy.get_game!(game.id)
    end

    @valid_user_attrs %{name: "jon"}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_user_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_games/0 returns all games" do
      game = game_fixture()
      assert Rummy.list_games() == [game]
    end

    test "get_game!/1 returns the game with given id" do
      game = game_fixture()
      assert Rummy.get_game!(game.id) == game
    end

    test "create_game/1 with valid data creates a game" do
      assert {:ok, %Game{} = game} = Rummy.create_game(@valid_attrs)
      assert game.discard_deck == []
      assert game.draw_deck == []
      assert game.name == "some name"
    end

    test "create_game/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Rummy.create_game(@invalid_attrs)
    end

    test "update_game/2 with valid data updates the game" do
      game = game_fixture()
      assert {:ok, game} = Rummy.update_game(game, @update_attrs)
      assert %Game{} = game
      assert game.discard_deck == []
      assert game.draw_deck == []
      assert game.name == "some updated name"
    end

    test "update_game/2 with invalid data returns error changeset" do
      game = game_fixture()
      assert {:error, %Ecto.Changeset{}} = Rummy.update_game(game, @invalid_attrs)
      assert game == Rummy.get_game!(game.id)
    end

    test "delete_game/1 deletes the game" do
      game = game_fixture()
      assert {:ok, %Game{}} = Rummy.delete_game(game)
      assert_raise Ecto.NoResultsError, fn -> Rummy.get_game!(game.id) end
    end

    test "change_game/1 returns a game changeset" do
      game = game_fixture()
      assert %Ecto.Changeset{} = Rummy.change_game(game)
    end

    test "game starts as new" do
      game = game_fixture()
      assert game.status == "new"
    end

    test "can start a game?" do
      assert False == Rummy.can_start_game?(game_fixture())
      assert True == Rummy.can_start_game?(game_with_users_fixture())
    end

    test "start a game" do
      assert {:error, "Not Enough players"} = Rummy.start_game(game_fixture())
      assert {:ok, %Game{status: "active"}} = Rummy.start_game(game_with_users_fixture())
    end

    test "add_player/2 adds a new player if it doesnt already exist and returns it" do
      game = game_fixture()
      user = user_fixture()
      assert Rummy.get_players(game) == []
      assert {:ok, player} = Rummy.add_player(game, user)
      assert player.user_id == user.id
      assert player.game_id == game.id
      assert Rummy.get_players(game) == [player]
    end

    test "add_player/2 returns error when player added twice" do
      game = game_fixture()
      user = user_fixture()
      {:ok, %Player{}} = Rummy.add_player(game, user)
      assert {:error, %Ecto.Changeset{}} = Rummy.add_player(game, user)
    end

    test "remove_player/1" do
      game = game_fixture()
      user = user_fixture()
      {:ok, player} = Rummy.add_player(game, user)
      assert Rummy.get_players(game) == [player]
      assert {:ok, %Player{}} = Rummy.remove_player(player)
      assert Rummy.get_players(game) == []
    end

    test "add_player/2 wont add players if game is full" do
      game = game_fixture()
      user1 = user_fixture(%{name: "Player 1"})
      user2 = user_fixture(%{name: "Player 2"})
      user3 = user_fixture(%{name: "Player 3"})
      user4 = user_fixture(%{name: "Player 4"})
      user5 = user_fixture(%{name: "Player 5"})
      assert {:ok, %Player{}} = Rummy.add_player(game, user1)
      assert {:ok, %Player{}} = Rummy.add_player(game, user2)
      assert {:ok, %Player{}} = Rummy.add_player(game, user3)
      assert {:ok, %Player{} = player4} = Rummy.add_player(game, user4)
      assert {:error, %Ecto.Changeset{} = changeset} = Rummy.add_player(game, user5)
      assert elem(changeset.errors[:game_id], 0) == "This game is full"
      Rummy.remove_player(player4)
      assert {:ok, %Player{}} = Rummy.add_player(game, user5)
    end

  end
end
