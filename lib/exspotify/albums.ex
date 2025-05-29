defmodule Exspotify.Albums do
  @moduledoc """
  Provides functions for interacting with the Albums endpoints of the Spotify Web API.
  See: https://developer.spotify.com/documentation/web-api/reference/albums
  """

  alias Exspotify.Client
  alias Exspotify.Structs.{Album, Track, Paging}

  @doc """
  Get Spotify catalog information for a single album identified by its unique Spotify ID.
  https://developer.spotify.com/documentation/web-api/reference/get-album
  """
  @spec get_album(String.t(), String.t()) :: {:ok, Album.t()} | {:error, any()}
  def get_album(album_id, token) do
    case Client.get("/albums/#{album_id}", [], token) do
      {:ok, album_map} -> {:ok, Album.from_map(album_map)}
      error -> error
    end
  end

  @doc """
  Get Spotify catalog information for multiple albums identified by their Spotify IDs.
  https://developer.spotify.com/documentation/web-api/reference/get-several-albums
  """
  @spec get_several_albums([String.t()], String.t()) :: {:ok, [Album.t()]} | {:error, any()}
  def get_several_albums(album_ids, token) when is_list(album_ids) do
    ids_param = Enum.join(album_ids, ",")
    case Client.get("/albums?ids=#{ids_param}", [], token) do
      {:ok, %{"albums" => albums_list}} ->
        albums = Enum.map(albums_list, &Album.from_map/1)
        {:ok, albums}
      error -> error
    end
  end

  @doc """
  Get Spotify catalog information about an album's tracks (paginated).
  https://developer.spotify.com/documentation/web-api/reference/get-albums-tracks
  """
  @spec get_album_tracks(String.t(), String.t(), keyword) :: {:ok, Paging.t()} | {:error, any()}
  def get_album_tracks(album_id, token, opts \\ []) do
    query = URI.encode_query(opts)
    path = "/albums/#{album_id}/tracks" <> if(query != "", do: "?#{query}", else: "")
    case Client.get(path, [], token) do
      {:ok, paging_map} ->
        parsed_paging = Paging.from_map(paging_map, &Track.from_map/1)
        {:ok, parsed_paging}
      error -> error
    end
  end

  @doc """
  Get a list of the albums saved in the current Spotify user's library (paginated).
  Returns a Paging struct containing saved albums with added_at timestamps.
  https://developer.spotify.com/documentation/web-api/reference/get-users-saved-albums
  """
  @spec get_users_saved_albums(String.t(), keyword) :: {:ok, Paging.t()} | {:error, any()}
  def get_users_saved_albums(token, opts \\ []) do
    query = URI.encode_query(opts)
    path = "/me/albums" <> if(query != "", do: "?#{query}", else: "")
    case Client.get(path, [], token) do
      {:ok, paging_map} ->
        # Parse items as maps with added_at and album fields (we removed SavedAlbum struct)
        parsed_paging = Paging.from_map(paging_map, fn item ->
          %{
            "added_at" => item["added_at"],
            "album" => Album.from_map(item["album"])
          }
        end)
        {:ok, parsed_paging}
      error -> error
    end
  end

  @doc """
  Save one or more albums to the current user's library.
  https://developer.spotify.com/documentation/web-api/reference/save-albums-user
  """
  @spec save_albums_for_current_user([String.t()], String.t()) :: {:ok, any()} | {:error, any()}
  def save_albums_for_current_user(album_ids, token) when is_list(album_ids) do
    query = URI.encode_query(%{"ids" => Enum.join(album_ids, ",")})
    Client.put("/me/albums?#{query}", %{}, [], token)
  end

  @doc """
  Remove one or more albums from the current user's library.
  https://developer.spotify.com/documentation/web-api/reference/remove-albums-user
  """
  @spec remove_users_saved_albums([String.t()], String.t()) :: {:ok, any()} | {:error, any()}
  def remove_users_saved_albums(album_ids, token) when is_list(album_ids) do
    query = URI.encode_query(%{"ids" => Enum.join(album_ids, ",")})
    Client.delete("/me/albums?#{query}", [], token)
  end

  @doc """
  Check if one or more albums are saved in the current user's library.
  Returns a list of booleans corresponding to the album IDs.
  https://developer.spotify.com/documentation/web-api/reference/check-users-saved-albums
  """
  @spec check_users_saved_albums([String.t()], String.t()) :: {:ok, [boolean()]} | {:error, any()}
  def check_users_saved_albums(album_ids, token) when is_list(album_ids) do
    query = URI.encode_query(%{"ids" => Enum.join(album_ids, ",")})
    Client.get("/me/albums/contains?#{query}", [], token)
  end

  @doc """
  Get a list of new album releases featured in Spotify (country optional).
  Returns a Paging struct containing new release albums.
  https://developer.spotify.com/documentation/web-api/reference/get-new-releases
  """
  @spec get_new_releases(String.t(), keyword) :: {:ok, Paging.t()} | {:error, any()}
  def get_new_releases(token, opts \\ []) do
    query = URI.encode_query(opts)
    path = "/browse/new-releases" <> if(query != "", do: "?#{query}", else: "")
    case Client.get(path, [], token) do
      {:ok, %{"albums" => paging_map}} ->
        parsed_paging = Paging.from_map(paging_map, &Album.from_map/1)
        {:ok, parsed_paging}
      error -> error
    end
  end
end
