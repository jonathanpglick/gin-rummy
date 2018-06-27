require IEx
defmodule App.Rummy.Player do
  use Ecto.Schema
  import Ecto.Changeset


  schema "players" do
    belongs_to :game, App.Rummy.Game
    belongs_to :user, App.Accounts.User
    field :cards, {:array, :string}, default: []

    timestamps()
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:game_id, :user_id, :cards])
    |> validate_required([:game_id, :user_id, :cards])
    |> unique_constraint(:user_id, name: :unique_game_players_index, message: "is already part of this game")
  end
end
