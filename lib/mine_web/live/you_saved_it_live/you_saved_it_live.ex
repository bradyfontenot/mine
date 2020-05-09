defmodule MineWeb.YouSavedItLive do
  use MineWeb, :live_view
  @moduledoc """
    storing entries twice.  using assigns as a temporary db
    of sorts to store unmolested list of entries for search/filter.

  """



  @impl true
  def mount(_params, %{"saved_list" => entries}, socket) do

    {:ok, assign(socket, [saves: entries, db: entries])}
  end


  @impl true
  def handle_event("search", %{"query" => %{"query" => query}}, socket) do
    
    filtered = Enum.filter(socket.assigns.db, fn entry ->
      entry["data"]["subreddit_name_prefixed"] =~ query end)

    {:noreply, assign(socket, [saves: filtered])}
  end

end
