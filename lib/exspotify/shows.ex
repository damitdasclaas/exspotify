defmodule Exspotify.Shows do
  @moduledoc """
  Provides functions for interacting with the Shows endpoints of the Spotify Web API.
  See: https://developer.spotify.com/documentation/web-api/reference/shows

  Note: The Shows API may not be fully supported by Spotify, may return 'resource not found', and does not have a dedicated scope. Use with caution.
  """

  alias Exspotify.Client
  alias Exspotify.Pagination

  @doc """
  Get Spotify catalog information for a single show by its unique Spotify ID.
  https://developer.spotify.com/documentation/web-api/reference/get-show
  """
  @spec get_show(String.t(), String.t()) :: any
  def get_show(show_id, token) do
    Client.get("/shows/#{show_id}", [], token)
  end

  @doc """
  Get Spotify catalog information for several shows based on their Spotify IDs.
  https://developer.spotify.com/documentation/web-api/reference/get-several-shows
  """
  @spec get_several_shows([String.t()], String.t()) :: any
  def get_several_shows(show_ids, token) when is_list(show_ids) do
    ids_param = Enum.join(show_ids, ",")
    Client.get("/shows?ids=#{ids_param}", [], token)
  end

  @doc """
  Get Spotify catalog information about a show's episodes (paginated).
  https://developer.spotify.com/documentation/web-api/reference/get-shows-episodes
  """
  @spec get_show_episodes(String.t(), String.t(), keyword) :: any
  def get_show_episodes(show_id, token, opts \\ []) do
    query = URI.encode_query(opts)
    path = "/shows/#{show_id}/episodes" <> if(query != "", do: "?#{query}", else: "")
    Client.get(path, [], token)
  end

  @doc """
  Fetches all episodes for a show, following all pages.

  **Warning:** This may make a large number of requests if the show has many episodes.
  You can limit the number of items fetched with the `:max_items` option (default: 200).
  """
  @spec get_all_show_episodes(String.t(), String.t(), keyword) :: [map]
  def get_all_show_episodes(show_id, token, opts \\ []) do
    max_items = Keyword.get(opts, :max_items, 200)
    fetch_page = fn page_opts -> get_show_episodes(show_id, token, page_opts) end
    Pagination.fetch_all(fetch_page, opts, max_items)
  end

  @doc """
  Get a list of the shows saved in the current Spotify user's library (paginated).
  https://developer.spotify.com/documentation/web-api/reference/get-users-saved-shows
  """
  @spec get_users_saved_shows(String.t(), keyword) :: any
  def get_users_saved_shows(token, opts \\ []) do
    query = URI.encode_query(opts)
    path = "/me/shows" <> if(query != "", do: "?#{query}", else: "")
    Client.get(path, [], token)
  end

  @doc """
  Fetches all saved shows for the user, following all pages.

  **Warning:** This may make a large number of requests if the user has many saved shows.
  You can limit the number of items fetched with the `:max_items` option (default: 200).
  """
  @spec get_all_users_saved_shows(String.t(), keyword) :: [map]
  def get_all_users_saved_shows(token, opts \\ []) do
    max_items = Keyword.get(opts, :max_items, 200)
    fetch_page = fn page_opts -> get_users_saved_shows(token, page_opts) end
    Pagination.fetch_all(fetch_page, opts, max_items)
  end

  @doc """
  Save one or more shows to the current user's library.
  https://developer.spotify.com/documentation/web-api/reference/save-shows-user
  """
  @spec save_shows_for_current_user([String.t()], String.t()) :: any
  def save_shows_for_current_user(show_ids, token) when is_list(show_ids) do
    query = URI.encode_query(%{"ids" => Enum.join(show_ids, ",")})
    Client.put("/me/shows?#{query}", %{}, [], token)
  end

  @doc """
  Remove one or more shows from the current user's library.
  https://developer.spotify.com/documentation/web-api/reference/remove-shows-user
  """
  @spec remove_users_saved_shows([String.t()], String.t()) :: any
  def remove_users_saved_shows(show_ids, token) when is_list(show_ids) do
    query = URI.encode_query(%{"ids" => Enum.join(show_ids, ",")})
    Client.delete("/me/shows?#{query}", [], token)
  end

  @doc """
  Check if one or more shows are saved in the current user's library.
  https://developer.spotify.com/documentation/web-api/reference/check-users-saved-shows
  """
  @spec check_users_saved_shows([String.t()], String.t()) :: any
  def check_users_saved_shows(show_ids, token) when is_list(show_ids) do
    query = URI.encode_query(%{"ids" => Enum.join(show_ids, ",")})
    Client.get("/me/shows/contains?#{query}", [], token)
  end
end
