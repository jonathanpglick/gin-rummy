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

  @doc """
  Can the game be started?
  """
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
  Current player.
  """
  def get_current_player!(%Game{status: "active"} = game) do
    Repo.get!(Player, game.current_player_id)
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

  @doc """
  Draw from draw deck.
  """
  def draw_from_deck(%Game{} = game, %Player{} = player) do
    [card | draw_deck] = game.draw_deck

    game_attrs =
      case length(draw_deck) do
        0 ->
          [top_discard_card | discard_deck] = game.discard_deck
          %{draw_deck: Enum.shuffle(discard_deck), discard_deck: [top_discard_card]}
        _ ->
          %{draw_deck: draw_deck}
      end

    result = Ecto.Multi.new()
      |> Ecto.Multi.update(:player, Player.changeset(player, %{cards: player.cards ++ [card]}))
      |> Ecto.Multi.update(:game, Game.changeset(game, game_attrs))
      |> Repo.transaction()

    case result do
      {:ok, %{game: game, player: player}} -> {:ok, game, player}
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Draw from discard deck.
  """
  def draw_from_discard(%Game{discard_deck: discard_deck} = game, %Player{} = player) when length(discard_deck) > 0 do
    [card | new_discard_deck] = discard_deck

    result = Ecto.Multi.new()
      |> Ecto.Multi.update(:player, Player.changeset(player, %{cards: player.cards ++ [card]}))
      |> Ecto.Multi.update(:game, Game.changeset(game, %{discard_deck: new_discard_deck}))
      |> Repo.transaction()

    case result do
      {:ok, %{game: game, player: player}} -> {:ok, game, player}
      {:error, error} -> {:error, error}
    end
  end

  def draw_from_discard(_game, _player) do
    {:error, "Insufficient cards"}
  end

  @doc """
  Can draw from discard.
  """
  def can_draw_from_discard?(%Game{} = game) do
    case length(game.discard_deck) do
      0 -> false
      _ -> true
    end
  end

  @doc """
  Discard a card.
  """
  def discard(%Game{} = _game, %Player{} = _player) do
  end

end
