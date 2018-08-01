defmodule AppWeb.PageController do
  use AppWeb, :controller

  alias App.Rummy

  def index(conn, _params) do
    render(conn, "index.html", games: Rummy.list_games())
  end
end
