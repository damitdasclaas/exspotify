defmodule Exspotify.Markets do
  @moduledoc """
  Provides functions for interacting with the Markets endpoint of the Spotify Web API.
  See: https://developer.spotify.com/documentation/web-api/reference/markets
  """

  alias Exspotify.Client

  @doc """
  Get the list of markets where Spotify is available.
  https://developer.spotify.com/documentation/web-api/reference/get-available-markets
  """
  @spec get_available_markets(String.t()) :: any
  def get_available_markets(token) do
    Client.get("/markets", [], token)
  end
end
