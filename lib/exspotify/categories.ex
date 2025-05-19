defmodule Exspotify.Categories do
  @moduledoc """
  Provides functions for interacting with the Categories endpoints of the Spotify Web API.
  See: https://developer.spotify.com/documentation/web-api/reference/categories
  """

  alias Exspotify.Client
  alias Exspotify.Pagination

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
  Fetches all categories, following all pages.

  **Warning:** This may make a large number of requests if there are many categories.
  You can limit the number of items fetched with the `:max_items` option (default: 200).
  """
  @spec get_all_categories(String.t(), keyword) :: [map]
  def get_all_categories(token, opts \\ []) do
    max_items = Keyword.get(opts, :max_items, 200)
    fetch_page = fn page_opts -> get_categories(token, page_opts) end
    Pagination.fetch_all(fetch_page, opts, max_items)
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
