defmodule App.Rummy.Game do
  use Ecto.Schema
  import Ecto.Changeset


  schema "games" do
    field :name, :string
    field :status, :string, default: "new"
    field :discard_deck, {:array, :string}
    field :draw_deck, {:array, :string}
    belongs_to :winner, App.Rummy.Player, [foreign_key: :winner_id]
    belongs_to :current_player, App.Rummy.Player, [foreign_key: :current_player_id]
    has_many :players, App.Rummy.Player

    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:name, :status, :draw_deck, :discard_deck])
    |> validate_required([:name, :status, :draw_deck, :discard_deck])
  end

end
