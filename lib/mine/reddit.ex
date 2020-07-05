defmodule Mine.Reddit do
  @moduledoc """
   	Reddit Api Wrapper.
     Connects to Reddit API
     using their Oauth2 connection
     to enable access to user related data.
  """
  use Tesla

  @client_id Application.get_env(:mine, :reddit_client_id)
  @api_key Application.get_env(:mine, :reddit_api_key)
  @redirect_uri Application.get_env(:mine, :reddit_redirect_uri)
  @scope "identity history"
  @duration "temporary"

  def get_auth_url do
    state = state_generator()

    auth_url =
      "https://ssl.reddit.com/api/v1/authorize.compact?client_id=#{@client_id}&response_type=code&state=#{
        state
      }&redirect_uri=#{@redirect_uri}&duration=#{@duration}&scope=#{@scope}"

    auth_url
  end

  # Client config to request token needed for authorized connection
  def client_for_token_request do
    middleware = [
      {Tesla.Middleware.BasicAuth, username: @client_id, password: @api_key},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers,
       [
         {"user-agent", "/u/elixirdev testing"},
         {"content-type", "application/x-www-form-urlencoded"}
       ]}
    ]

    Tesla.client(middleware)
  end

  def request_token(code) do
    client = client_for_token_request()
    uri = "https://www.reddit.com/api/v1/access_token"
    body = "grant_type=authorization_code&code=#{code}&redirect_uri=#{@redirect_uri}"

    case post(client, uri, body) do
      {:ok, %{body: %{"access_token" => _}}} = {:ok, response} ->
        response.body["access_token"]

      {:ok, %{body: %{"error" => _}}} = {:ok, response} ->
        response.body["error"]
    end
  end

  # Authorized client connection
  def client_for_saves_request(token) do
    middleware = [
      {Tesla.Middleware.BaseUrl, "https://oauth.reddit.com"},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers,
       [
         {"authorization", "bearer #{token}"},
         {"user-agent", "/u/elixirdev testing"}
       ]}
    ]

    Tesla.client(middleware)
  end

  def get_username(client) do
    {:ok, response} = get(client, "/api/v1/me")

    response.body["name"]
  end

  # Retrieves list of user's saved comments & posts
  def get_user_saves(code) do
    case request_token(code) do
      "invalid_grant" ->
        {:error, "invalid_grant"}

      token ->
        client = client_for_saves_request(token)
        username = get_username(client)
        url = "/user/#{username}/saved/?raw_json=1&limit=100"

        # {:ok, response} = get(client, url)
        # response.body["data"]["children"]
        get_all(client, url)
        # saves
    end
  end

  @doc """
    Grabs 100 entries/request (reddit limit)
    recursively until end of list is hit.
  """
  defp get_all(client, url) do
    case get(client, url) do
      {:ok, response} ->
        next = response.body["data"]["after"]
        entries = response.body["data"]["children"]
        current_url = "#{url}&after=#{next}"
        entries ++ get_all(client, current_url, next)

      {:error, _} ->
        {:error, "invalid_grant"}
    end
  end

  defp get_all(_client, _url, nil), do: []

  defp get_all(client, url, _next) do
    case get(client, url) do
      {:ok, response} ->
        next = response.body["data"]["after"]
        entries = response.body["data"]["children"]
        current_url = "#{url}&after=#{next}"
        entries ++ get_all(client, current_url, next)

      {:error, _} ->
        {:error, "invalid_grant"}
    end
  end

  @doc """
  generates random string to use as query param to help verify
  validity of source.
  source: Dan Schultzer(github.com/danschultzer/generator.ex)
  """
  defp state_generator() do
    min = String.to_integer("100000", 36)
    max = String.to_integer("ZZZZZZ", 36)

    max
    |> Kernel.-(min)
    |> :rand.uniform()
    |> Kernel.+(min)
    |> Integer.to_string(36)
  end
end
