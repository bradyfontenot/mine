defmodule MineWeb.SavedController do
  use MineWeb, :controller

  import Phoenix.LiveView.Controller

  alias Mine.Reddit

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
