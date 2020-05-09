defmodule MineWeb.CountriesLive do
  use MineWeb, :live_view
  
  alias Mine.CountriesApi


  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      data = CountriesApi.list_countries()
      {:ok, assign(socket, :data, data.body)}
    end

    {:ok, assign(socket, :data, "")}
  end


end