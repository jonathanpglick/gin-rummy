defmodule App.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table(:games) do
      add :name, :string
      add :status, :string
      add :draw_deck, {:array, :string}
      add :discard_deck, {:array, :string}

      timestamps()
    end

    create table(:players) do
      add :game_id, references(:games, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)
      add :cards, {:array, :string}

      timestamps()
    end

    create unique_index(:players, [:game_id, :user_id], name: :unique_game_players_index)

    alter table(:games) do
      add :winner_id, references(:players)
      add :current_player_id, references(:players)
    end

  end
end
