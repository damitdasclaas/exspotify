defmodule Exspotify.Categories do
  @moduledoc """
  Provides functions for interacting with the Categories endpoints of the Spotify Web API.
  See: https://developer.spotify.com/documentation/web-api/reference/categories
  """

  alias Exspotify.Client

  @doc """
  Get a list of categories used to tag items in Spotify (paginated).
  https://developer.spotify.com/documentation/web-api/reference/get-categories
  """
  @spec get_categories(String.t(), keyword) :: any
  def get_categories(token, opts \\ []) do
    query = URI.encode_query(opts)
    path = "/browse/categories" <> if(query != "", do: "?#{query}", else: "")
    case Client.get(path, [], token) do
      {:ok, %{"categories" => categories}} -> {:ok, categories}
      other -> other
    end
  end

  @doc """
  Get a single category by its unique Spotify category ID.
  https://developer.spotify.com/documentation/web-api/reference/get-category
  """
  @spec get_category(String.t(), String.t(), keyword) :: any
  def get_category(category_id, token, opts \\ []) do
    query = URI.encode_query(opts)
    path = "/browse/categories/#{category_id}" <> if(query != "", do: "?#{query}", else: "")
    Client.get(path, [], token)
  end
end
