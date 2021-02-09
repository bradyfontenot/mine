defmodule MineWeb.YouSavedItLive do
  use MineWeb, :live_view

  @moduledoc """
  
  """

  @impl true
  def mount(_params, %{"saved_list" => entries}, socket) do
    :ets.new(:saved_table, [:bag, :named_table])
    :ets.insert(:saved_table, {:saved_list, entries})
    [saved_list: entries] = :ets.lookup(:saved_table, :saved_list)

    {:ok, assign(socket, saves: entries, type: "all")}
  end

  # filter by search term
  @impl true
  def handle_event("search", %{"query" => %{"query" => query}}, socket) do
    [saved_list: entries] = :ets.lookup(:saved_table, :saved_list)

    filtered =
      filter_by_type(socket.assigns.type, entries)
      |> filter_by_query(query)

    {:noreply, assign(socket, saves: filtered)}
  end

  # show all
  def handle_event("all", _, socket) do
    [saved_list: entries] = :ets.lookup(:saved_table, :saved_list)

    {:noreply, assign(socket, saves: entries, type: "all")}
  end

  # filter by posts
  def handle_event("posts", _, socket) do
    [saved_list: entries] = :ets.lookup(:saved_table, :saved_list)

    filtered = filter_by_type("t3", entries)

    {:noreply, assign(socket, saves: filtered, type: "t3")}
  end

  # filter by comments
  def handle_event("comments", _, socket) do
    [saved_list: entries] = :ets.lookup(:saved_table, :saved_list)

    filtered = filter_by_type("t1", entries)

    {:noreply, assign(socket, saves: filtered, type: "t1")}
  end

  defp filter_by_type("all", entries), do: entries

  defp filter_by_type(type, entries) do
    filtered = Enum.filter(entries, fn entry -> entry["kind"] == type end)

    case type do
      "t1" ->
        filtered

      "t3" ->
        Enum.sort_by(filtered, & &1["data"]["subreddit_name_prefixed"], :asc)
    end
  end

  defp filter_by_query(entries, query) do
    Enum.filter(entries, fn entry ->
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
