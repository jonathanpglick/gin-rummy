defmodule AppWeb.PageController do
  use AppWeb, :controller

  alias App.Rummy

  def index(conn, _params) do
    render(conn, "index.html", games: Rummy.list_games())
  end

  def show_game(conn, %{"game" => game_id}) do
    game = Rummy.get_game!(game_id)
    current_player = Rummy.get_current_player!(game)
    players = Rummy.get_players(game)
    render(conn, "game.html", game: game, current_player: current_player, players: players)
  end
end
