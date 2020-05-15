defmodule MineWeb.YouSavedItLive do
  use MineWeb, :live_view

  @moduledoc """
    REDO using cache or local-storage: 
    currently storing entries twice.  using assigns as a temporary db
    of sorts to store unmolested list of entries for search/filter.
  """

  @impl true
  def mount(_params, %{"saved_list" => entries}, socket) do
    {:ok, assign(socket, saves: entries, fake_db: entries, type: "all")}
  end

  # filter by search term
  @impl true
  def handle_event("search", %{"query" => %{"query" => query}}, socket) do
    filtered =
      filter_by_type(socket.assigns.type, socket.assigns.fake_db)
      |> filter_by_query(query)

    {:noreply, assign(socket, saves: filtered)}
  end

  # show all
  def handle_event("all", _, socket) do
    {:noreply, assign(socket, saves: socket.assigns.fake_db, type: "all")}
  end

  # filter by posts
  def handle_event("posts", _, socket) do
    filtered = filter_by_type("t3", socket.assigns.fake_db)

    {:noreply, assign(socket, saves: filtered, type: "t3")}
  end

  # filter by comments
  def handle_event("comments", _, socket) do
    filtered = filter_by_type("t1", socket.assigns.fake_db)

    {:noreply, assign(socket, saves: filtered, type: "t1")}
  end

  defp filter_by_type("all", db), do: db

  defp filter_by_type(type, db) do
    filtered = Enum.filter(db, fn entry -> entry["kind"] == type end)

    case type do
      "t1" ->
        filtered

      "t3" ->
        Enum.sort_by(filtered, & &1["data"]["subreddit_name_prefixed"], :asc)
    end
  end

  defp filter_by_query(db, query) do
    Enum.filter(db, fn entry ->
      pattern =
        Enum.join([
          entry["data"]["subreddit_name_prefixed"],
          entry["data"]["link_title"],
          entry["data"]["title"],
          entry["data"]["body"]
        ])
        |> String.downcase()

      String.contains?(pattern, String.downcase(query)) == true
    end)
  end
end
