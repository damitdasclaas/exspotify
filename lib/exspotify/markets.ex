defmodule Exspotify.Markets do
  @moduledoc """
  Provides functions for interacting with the Markets endpoints of the Spotify Web API.
  See: https://developer.spotify.com/documentation/web-api/reference/markets
  """

  alias Exspotify.{Client, Error}

  @doc """
  Get a list of countries in which Spotify is available.
  Returns a list of ISO 3166-1 alpha-2 country codes.
  https://developer.spotify.com/documentation/web-api/reference/get-available-markets
  """
  @spec get_available_markets(String.t()) :: {:ok, [String.t()]} | {:error, Error.t()}
  def get_available_markets(token) do
    with :ok <- Error.validate_token(token),
         {:ok, response} <- Client.get("/markets", [], token) do
      case response do
        %{"markets" => markets_list} when is_list(markets_list) -> {:ok, markets_list}
        _ -> {:error, Error.new(:unexpected_response, "Expected markets array in response", %{response: response})}
      end
    end
  end
end
