defmodule App.RummyTest do
  use App.DataCase

  alias App.Rummy
  alias App.Accounts

  describe "games" do
    alias App.Accounts.User
    alias App.Rummy.Game
    alias App.Rummy.Player

    @valid_attrs %{discard_deck: [], draw_deck: [], name: "some name", status: "some status"}
    @update_attrs %{discard_deck: [], draw_deck: [], name: "some updated name", status: "some updated status"}
    @invalid_attrs %{discard_deck: nil, draw_deck: nil, name: nil, status: nil}

    def game_fixture(attrs \\ %{}) do
      {:ok, game} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Rummy.create_game()

      game
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
      assert game.status == "some status"
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
      assert game.status == "some updated status"
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
      {:ok, player} = Rummy.add_player(game, user)
      assert {:error, %Ecto.Changeset{} = changeset} = Rummy.add_player(game, user)
    end
  end
end
