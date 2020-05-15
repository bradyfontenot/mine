defmodule MineWeb.SavedController do
  use MineWeb, :controller

  import Phoenix.LiveView.Controller

  alias Mine.Reddit

  # def index(conn, params) do

  # 	token = Reddit.request_token(params["code"])

  #   case token do
  #     token = "invalid_grant" -> 
  #       conn
  #       |> put_flash(:error, "Shit went wrong bro!")
  #       |> redirect(to: "/")

  #     _ ->
  #       {:ok, response} = Reddit.get_user_saves(token)
  #       # json(conn, response.body)
  #       render(conn, "index.html", saves: response.body)
  #   end

  # end

  def index(conn, params) do
    case Reddit.get_user_saves(params["code"]) do
      {:error, "invalid_grant"} ->
        {:ok,
         conn
         |> put_flash(:error, "Try again please. Reddit seems to be a little moody.")
         |> redirect(to: "/")}

      entries ->
        live_render(conn, MineWeb.YouSavedItLive, session: %{"saved_list" => entries})
    end
  end
end
