defmodule Exspotify.Playlists do
  @moduledoc """
  Provides functions for interacting with the Playlists endpoints of the Spotify Web API.
  Deprecated endpoints (featured playlists, category playlists) are not included.
  See: https://developer.spotify.com/documentation/web-api/reference/playlists
  """

  alias Exspotify.Client
  alias Exspotify.Pagination

  @doc """
  Get a playlist by its Spotify ID.
  Requires: playlist-read-private or playlist-read-collaborative scope for private playlists.
  """
  @spec get_playlist(String.t(), String.t()) :: any
  def get_playlist(playlist_id, token) do
    Client.get("/playlists/#{playlist_id}", [], token)
  end

  @doc """
  Change a playlist's details (name, description, public, collaborative).
  **Warning:** This will change the playlist's metadata.
  Requires: playlist-modify-public or playlist-modify-private scope.
  """
  @spec change_playlist_details(String.t(), String.t(), map) :: any
  def change_playlist_details(playlist_id, token, details) do
    Client.put("/playlists/#{playlist_id}", details, [], token)
  end

  @doc """
  Get items (tracks/episodes) in a playlist (paginated).
  https://developer.spotify.com/documentation/web-api/reference/get-playlists-tracks
  """
  @spec get_playlist_items(String.t(), String.t(), keyword) :: any
  def get_playlist_items(playlist_id, token, opts \\ []) do
    query = URI.encode_query(opts)
    path = "/playlists/#{playlist_id}/tracks" <> if(query != "", do: "?#{query}", else: "")
    Client.get(path, [], token)
  end

  @doc """
  Fetches all items in a playlist, following all pages.

  **Warning:** This may make a large number of requests if the playlist is large.
  You can limit the number of items fetched with the `:max_items` option (default: 200).
  """
  @spec get_all_playlist_items(String.t(), String.t(), keyword) :: [map]
  def get_all_playlist_items(playlist_id, token, opts \\ []) do
    max_items = Keyword.get(opts, :max_items, 200)
    fetch_page = fn page_opts -> get_playlist_items(playlist_id, token, page_opts) end
    Pagination.fetch_all(fetch_page, opts, max_items)
  end

  @doc """
  Update (reorder/replace) items in a playlist.
  **Warning:** This will change the playlist's items.
  Requires: playlist-modify-public or playlist-modify-private scope.
  """
  @spec update_playlist_items(String.t(), String.t(), map, keyword) :: any
  def update_playlist_items(playlist_id, token, body, opts \\ []) do
    query = URI.encode_query(opts)
    path = "/playlists/#{playlist_id}/tracks" <> if(query != "", do: "?#{query}", else: "")
    Client.put(path, body, [], token)
  end

  @doc """
  Add items (tracks/episodes) to a playlist.
  **Warning:** This will change the playlist's items.
  Requires: playlist-modify-public or playlist-modify-private scope.
  """
  @spec add_items_to_playlist(String.t(), String.t(), map) :: any
  def add_items_to_playlist(playlist_id, token, body) do
    Client.post("/playlists/#{playlist_id}/tracks", body, [], token)
  end

  @doc """
  Remove items (tracks/episodes) from a playlist.
  **Warning:** This will change the playlist's items.
  Requires: playlist-modify-public or playlist-modify-private scope.
  """
  @spec remove_playlist_items(String.t(), String.t(), map) :: any
  def remove_playlist_items(playlist_id, token, body) do
    Client.delete("/playlists/#{playlist_id}/tracks", body, [], token)
  end

  @doc """
  Get the current user's playlists (paginated).
  https://developer.spotify.com/documentation/web-api/reference/get-current-users-playlists
  """
  @spec get_current_users_playlists(String.t(), keyword) :: any
  def get_current_users_playlists(token, opts \\ []) do
    query = URI.encode_query(opts)
    path = "/me/playlists" <> if(query != "", do: "?#{query}", else: "")
    Client.get(path, [], token)
  end

  @doc """
  Fetches all playlists for the current user, following all pages.
  **Warning:** This may make a large number of requests if the user has many playlists.
  You can limit the number of items fetched with the `:max_items` option (default: 200).
  """
  @spec get_all_current_users_playlists(String.t(), keyword) :: [map]
  def get_all_current_users_playlists(token, opts \\ []) do
    max_items = Keyword.get(opts, :max_items, 200)
    fetch_page = fn page_opts -> get_current_users_playlists(token, page_opts) end
    Pagination.fetch_all(fetch_page, opts, max_items)
  end

  @doc """
  Get a user's public playlists (paginated).
  https://developer.spotify.com/documentation/web-api/reference/get-list-users-playlists
  """
  @spec get_users_playlists(String.t(), String.t(), keyword) :: any
  def get_users_playlists(user_id, token, opts \\ []) do
    query = URI.encode_query(opts)
    path = "/users/#{user_id}/playlists" <> if(query != "", do: "?#{query}", else: "")
    Client.get(path, [], token)
  end

  @doc """
  Fetches all playlists for a user, following all pages.
  **Warning:** This may make a large number of requests if the user has many playlists.
  You can limit the number of items fetched with the `:max_items` option (default: 200).
  """
  @spec get_all_users_playlists(String.t(), String.t(), keyword) :: [map]
  def get_all_users_playlists(user_id, token, opts \\ []) do
    max_items = Keyword.get(opts, :max_items, 200)
    fetch_page = fn page_opts -> get_users_playlists(user_id, token, page_opts) end
    Pagination.fetch_all(fetch_page, opts, max_items)
  end

  @doc """
  Create a playlist for a user.
  **Warning:** This will create a new playlist in the user's account.
  Requires: playlist-modify-public or playlist-modify-private scope.
  """
  @spec create_playlist(String.t(), String.t(), String.t(), map) :: any
  def create_playlist(user_id, token, name, opts \\ %{}) do
    body = Map.put(opts, :name, name)
    Client.post("/users/#{user_id}/playlists", body, [], token)
  end

  @doc """
  Get the current image for a playlist.
  """
  @spec get_playlist_cover_image(String.t(), String.t()) :: any
  def get_playlist_cover_image(playlist_id, token) do
    Client.get("/playlists/#{playlist_id}/images", [], token)
  end

  @doc """
  Add a custom cover image to a playlist.
  **Warning:** This will change the playlist's cover image.
  Requires: playlist-modify-public or playlist-modify-private scope.
  The image must be a Base64-encoded JPEG.
  """
  @spec add_custom_playlist_cover_image(String.t(), String.t(), String.t()) :: any
  def add_custom_playlist_cover_image(playlist_id, token, base64_jpeg) do
    headers = [{"Content-Type", "image/jpeg"}]
    Client.put("/playlists/#{playlist_id}/images", base64_jpeg, headers, token)
  end

  @doc """
  Follow a playlist.
  **Warning:** This will add the playlist to the user's library.
  Requires: playlist-modify-public or playlist-modify-private scope.
  """
  @spec follow_playlist(String.t(), String.t(), map) :: any
  def follow_playlist(playlist_id, token, opts \\ %{}) do
    Client.put("/playlists/#{playlist_id}/followers", opts, [], token)
  end

  @doc """
  Unfollow a playlist.
  **Warning:** This will remove the playlist from the user's library.
  Requires: playlist-modify-public or playlist-modify-private scope.
  """
  @spec unfollow_playlist(String.t(), String.t()) :: any
  def unfollow_playlist(playlist_id, token) do
    Client.delete("/playlists/#{playlist_id}/followers", %{}, [], token)
  end

  @doc """
  Check if one or more users are following a playlist.
  """
  @spec check_if_user_follows_playlist(String.t(), String.t(), [String.t()]) :: any
  def check_if_user_follows_playlist(playlist_id, token, user_ids) when is_list(user_ids) do
    query = URI.encode_query(%{"ids" => Enum.join(user_ids, ",")})
    Client.get("/playlists/#{playlist_id}/followers/contains?#{query}", [], token)
  end
end
