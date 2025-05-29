defmodule Exspotify.Markets do
  @moduledoc """
  Provides functions for interacting with the Markets endpoints of the Spotify Web API.
  See: https://developer.spotify.com/documentation/web-api/reference/markets
  """

  alias Exspotify.Client

  @doc """
  Get a list of countries in which Spotify is available.
  Returns a list of ISO 3166-1 alpha-2 country codes.
  https://developer.spotify.com/documentation/web-api/reference/get-available-markets
  """
  @spec get_available_markets(String.t()) :: {:ok, [String.t()]} | {:error, any()}
  def get_available_markets(token) do
    case Client.get("/markets", [], token) do
      {:ok, %{"markets" => markets_list}} -> {:ok, markets_list}
      error -> error
    end
  end
end
