# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     App.Repo.insert!(%App.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

defmodule App.DbSeeder do
  alias App.Repo
  alias App.Rummy
  alias App.Accounts.User
  alias App.Rummy.Game
  alias App.Rummy.Player

  Repo.delete_all(User)
  jon = Repo.insert!(%User{name: "Jon"})
  jen = Repo.insert!(%User{name: "Jen"})

  Repo.delete_all(Game)
  game1 = Repo.insert!(%Game{name: "Game 1"})

  Repo.delete_all(Player)
  Rummy.add_player(game1, jon)
  Rummy.add_player(game1, jen)
end
