defmodule Exspotify.Categories do
  @moduledoc """
  Provides functions for interacting with the Categories endpoints of the Spotify Web API.
  See: https://developer.spotify.com/documentation/web-api/reference/categories
  """

  alias Exspotify.Client
  alias Exspotify.Structs.{Category, Paging}

  @doc """
  Get a list of categories used to tag items in Spotify (paginated).
  https://developer.spotify.com/documentation/web-api/reference/get-categories
  """
  @spec get_several_browse_categories(String.t(), keyword) :: {:ok, Paging.t()} | {:error, any()}
  def get_several_browse_categories(token, opts \\ []) do
    query = URI.encode_query(opts)
    path = "/browse/categories" <> if(query != "", do: "?#{query}", else: "")
    case Client.get(path, [], token) do
      {:ok, %{"categories" => paging_map}} ->
        parsed_paging = Paging.from_map(paging_map, &Category.from_map/1)
        {:ok, parsed_paging}
      error -> error
    end
  end

  @doc """
  Get a single category used to tag items in Spotify.
  https://developer.spotify.com/documentation/web-api/reference/get-category
  """
  @spec get_single_browse_category(String.t(), String.t(), keyword) :: {:ok, Category.t()} | {:error, any()}
  def get_single_browse_category(category_id, token, opts \\ []) do
    query = URI.encode_query(opts)
    path = "/browse/categories/#{category_id}" <> if(query != "", do: "?#{query}", else: "")
    case Client.get(path, [], token) do
      {:ok, category_map} -> {:ok, Category.from_map(category_map)}
      error -> error
    end
  end
end
