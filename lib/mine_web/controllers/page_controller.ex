defmodule MineWeb.PageController do
  use MineWeb, :controller

  alias Mine.Reddit

  def index(conn, _params) do
  	auth_url = Reddit.get_auth_url()
  	IO.inspect(auth_url,label: "*********************")
    render(conn, "index.html", reddit_auth: auth_url)
  end
end
