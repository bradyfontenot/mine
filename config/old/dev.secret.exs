use Mix.Config

reddit_api_key =
  System.get_env("REDDIT_API_KEY") ||
    raise """
    environment variable REDDIT_API_KEY is missing.
    """

reddit_client_id =
  System.get_env("REDDIT_CLIENT_ID") ||
    raise """
    environment variable REDDIT_API_KEY is missing.
    """

config :mine, reddit_api_key: reddit_api_key
config :mine, reddit_client_id: reddit_client_id
