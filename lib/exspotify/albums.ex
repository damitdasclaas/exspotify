defmodule Exspotify.Albums do
  @moduledoc """
  Provides functions for interacting with the Albums endpoints of the Spotify Web API.
  See: https://developer.spotify.com/documentation/web-api/reference/albums
  """

  alias Exspotify.Client

  @doc """
  Get Spotify catalog information for a single album identified by its unique Spotify ID.
  https://developer.spotify.com/documentation/web-api/reference/get-album
  """
  @spec get_album(String.t(), String.t()) :: any
  def get_album(album_id, token) do
    # Implementation will call Client.get/3
    Client.get("/albums/#{album_id}", [], token)
  end

  @doc """
  Get Spotify catalog information for multiple albums identified by their Spotify IDs.
  https://developer.spotify.com/documentation/web-api/reference/get-several-albums
  """
  @spec get_several_albums([String.t()], String.t()) :: any
  def get_several_albums(album_ids, token) when is_list(album_ids) do
    ids_param = Enum.join(album_ids, ",")
    Client.get("/albums?ids=#{ids_param}", [], token)
  end

  @doc """
  Get Spotify catalog information about an album's tracks.
  https://developer.spotify.com/documentation/web-api/reference/get-albums-tracks
  """
  @spec get_album_tracks(String.t(), String.t(), keyword) :: any
  def get_album_tracks(album_id, token, opts \\ []) do
    query = URI.encode_query(opts)
    path = "/albums/#{album_id}/tracks" <> if(query != "", do: "?#{query}", else: "")
    Client.get(path, [], token)
  end

  @doc """
  Get a list of the albums saved in the current Spotify user's library.
  https://developer.spotify.com/documentation/web-api/reference/get-users-saved-albums
  """
  @spec get_users_saved_albums(String.t(), keyword) :: any
  def get_users_saved_albums(token, opts \\ []) do
    query = URI.encode_query(opts)
    path = "/me/albums" <> if(query != "", do: "?#{query}", else: "")
    Client.get(path, [], token)
  end

  @doc """
  Save one or more albums to the current user's library.
  https://developer.spotify.com/documentation/web-api/reference/save-albums-user
  """
  @spec save_albums_for_current_user([String.t()], String.t()) :: any
  def save_albums_for_current_user(album_ids, token) when is_list(album_ids) do
    query = URI.encode_query(%{"ids" => Enum.join(album_ids, ",")})
    Client.put("/me/albums?#{query}", %{}, [], token)
  end

  @doc """
  Remove one or more albums from the current user's library.
  https://developer.spotify.com/documentation/web-api/reference/remove-albums-user
  """
  @spec remove_users_saved_albums([String.t()], String.t()) :: any
  def remove_users_saved_albums(album_ids, token) when is_list(album_ids) do
    query = URI.encode_query(%{"ids" => Enum.join(album_ids, ",")})
    Client.delete("/me/albums?#{query}", [], token)
  end

  @doc """
  Check if one or more albums are saved in the current user's library.
  https://developer.spotify.com/documentation/web-api/reference/check-users-saved-albums
  """
  @spec check_users_saved_albums([String.t()], String.t()) :: any
  def check_users_saved_albums(album_ids, token) when is_list(album_ids) do
    query = URI.encode_query(%{"ids" => Enum.join(album_ids, ",")})
    Client.get("/me/albums/contains?#{query}", [], token)
  end

  @doc """
  Get a list of new album releases featured in Spotify (country optional).
  https://developer.spotify.com/documentation/web-api/reference/get-new-releases
  """
  @spec get_new_releases(String.t(), keyword) :: any
  def get_new_releases(token, opts \\ []) do
    query = URI.encode_query(opts)
    path = "/browse/new-releases" <> if(query != "", do: "?#{query}", else: "")
    Client.get(path, [], token)
  end
end
