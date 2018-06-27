defmodule App.Rummy.Player do
  use Ecto.Schema
  import Ecto.Changeset


  schema "players" do
    belongs_to :user, App.Accounts.User
    belongs_to :game, App.Rummy.Game
    field :cards, {:array, :string}

    timestamps()
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:cards])
    |> validate_required([:cards])
  end
end
