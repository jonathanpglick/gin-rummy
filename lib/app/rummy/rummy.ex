defmodule App.Rummy do
  @moduledoc """
  The Rummy context.
  """

  import Ecto.Query, warn: false
  alias App.Repo

  alias App.Accounts.User
  alias App.Rummy.Game
  alias App.Rummy.Player
  alias App.Rummy.Deck

  @doc """
  Returns the list of games.

  ## Examples

      iex> list_games()
      [%Game{}, ...]

  """
  def list_games do
    Repo.all(Game)
  end

  @doc """
  Gets a single game.

  Raises `Ecto.NoResultsError` if the Game does not exist.

  ## Examples

      iex> get_game!(123)
      %Game{}

      iex> get_game!(456)
      ** (Ecto.NoResultsError)

  """
  def get_game!(id) do
    Repo.get!(Game, id)
  end

  @doc """
  Creates a game.

  ## Examples

      iex> create_game(%{field: value})
      {:ok, %Game{}}

      iex> create_game(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_game(attrs \\ %{}) do
    %Game{}
    |> Game.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a game.

  ## Examples

      iex> update_game(game, %{field: new_value})
      {:ok, %Game{}}

      iex> update_game(game, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_game(%Game{} = game, attrs) do
    game
    |> Game.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Game.

  ## Examples

      iex> delete_game(game)
      {:ok, %Game{}}

      iex> delete_game(game)
      {:error, %Ecto.Changeset{}}

  """
  def delete_game(%Game{} = game) do
    Repo.delete(game)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking game changes.

  ## Examples

      iex> change_game(game)
      %Ecto.Changeset{source: %Game{}}

  """
  def change_game(%Game{} = game) do
    Game.changeset(game, %{})
  end


  @doc """
  Starts a game.
  """
  def start_game(%Game{status: "new"} = game) do
    case can_start_game?(game) do
      true ->
        players = get_players(game)
        first_player = List.first(Enum.shuffle(players))
        deck = Deck.get_shuffled_deck()
        {hands, draw_deck} = Deck.deal(deck, length(players))
        players_and_hands = Enum.zip(players, hands)

        multi = Ecto.Multi.new()

        multi = players_and_hands
          |> Enum.reduce(multi, fn ({player, hand}, multi) ->
            Ecto.Multi.update(multi, String.to_atom("player_#{player.id}"), Player.changeset(player, %{cards: hand}))
          end)

        multi = multi
          |> Ecto.Multi.update(:game, Game.changeset(game, %{
            status: "active",
            draw_deck: draw_deck,
            current_player_id: first_player.id
          }))

        result = multi |> Repo.transaction()

        case result do
          {:ok, %{game: game}} -> {:ok, game}
          {:error, error} -> {:error, error}
        end

      false ->
        {:error, "Not Enough players"}
    end
  end

  def can_start_game?(%Game{status: "new"} = game) do
    if length(get_players(game)) >= 2 do
      true
    else
      false
    end
  end

  @doc """
  Otherwise false
  """
  def can_start_game?(_game) do
    false
  end

  @doc """
  Gets the players for a game.
  """
  def get_players(%Game{id: game_id}) do
    Player
    |> where([p], p.game_id == ^game_id)
    |> Repo.all()
  end

  @doc """
  Adds a player to a game.
  """
  def add_player(%Game{} = game, %User{} = user) do
    Repo.insert(Player.insert_changeset(%Player{}, %{game_id: game.id, user_id: user.id}))
  end

  @doc """
  Removes a player from a game.
  """
  def remove_player(%Player{} = player) do
    Repo.delete(player)
  end

end
