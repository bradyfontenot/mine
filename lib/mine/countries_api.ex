defmodule Mine.CountriesApi do
  use Tesla, only: [:get], docs: false

  plug Tesla.Middleware.BaseUrl, "https://restcountries.eu/rest/v2"
  plug Tesla.Middleware.JSON

  def list_countries do
   {:ok, response} = get("/all")
   IO.inspect(response)
   response
  end
end