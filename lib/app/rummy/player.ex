require IEx

defmodule App.Rummy.Player do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false
  alias App.Rummy.Player
  alias App.Repo

  @max_players_per_game 4

  schema "players" do
    belongs_to(:game, App.Rummy.Game)
    belongs_to(:user, App.Accounts.User)
    field(:cards, {:array, :string}, default: [])

    timestamps()
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:game_id, :user_id, :cards])
    |> validate_required([:game_id, :user_id, :cards])
    |> unique_constraint(:user_id,
      name: :unique_game_players_index,
      message: "is already part of this game"
    )
  end

  @doc false
  def insert_changeset(player, attrs) do
    player
    |> cast(attrs, [:game_id, :user_id, :cards])
    |> validate_required([:game_id, :user_id, :cards])
    |> validate_max_players_per_game()
    |> unique_constraint(:user_id,
      name: :unique_game_players_index,
      message: "is already part of this game"
    )
  end

  defp validate_max_players_per_game(changeset) do
    game_id = get_field(changeset, :game_id)

    players_count =
      Player
      |> where([p], p.game_id == ^game_id)
      |> Repo.aggregate(:count, :id)

    new_players_count = players_count + 1

    if new_players_count > @max_players_per_game do
      add_error(changeset, :game_id, "This game is full")
    else
      changeset
    end
  end
end
