defmodule Exspotify.Artists do
  @moduledoc """
  Provides functions for interacting with the Artists endpoints of the Spotify Web API.
  See: https://developer.spotify.com/documentation/web-api/reference/artists

  Note: The 'related artists' endpoint is deprecated and not included in this module.
  """

  alias Exspotify.Client
  alias Exspotify.Pagination

  @doc """
  Get Spotify catalog information for a single artist by their unique Spotify ID.
  https://developer.spotify.com/documentation/web-api/reference/get-artist
  """
  @spec get_artist(String.t(), String.t()) :: any
  def get_artist(artist_id, token) do
    Client.get("/artists/#{artist_id}", [], token)
  end

  @doc """
  Get Spotify catalog information for several artists based on their Spotify IDs.
  https://developer.spotify.com/documentation/web-api/reference/get-several-artists
  """
  @spec get_several_artists([String.t()], String.t()) :: any
  def get_several_artists(artist_ids, token) when is_list(artist_ids) do
    ids_param = Enum.join(artist_ids, ",")
    Client.get("/artists?ids=#{ids_param}", [], token)
  end

  @doc """
  Get Spotify catalog information about an artist's albums (paginated).
  https://developer.spotify.com/documentation/web-api/reference/get-an-artists-albums
  """
  @spec get_artist_albums(String.t(), String.t(), keyword) :: any
  def get_artist_albums(artist_id, token, opts \\ []) do
    query = URI.encode_query(opts)
    path = "/artists/#{artist_id}/albums" <> if(query != "", do: "?#{query}", else: "")
    Client.get(path, [], token)
  end

  @doc """
  Fetches all albums for an artist, following all pages.

  **Warning:** This may make a large number of requests if the artist has many albums.
  You can limit the number of items fetched with the `:max_items` option (default: 200).
  """
  @spec get_all_artist_albums(String.t(), String.t(), keyword) :: [map]
  def get_all_artist_albums(artist_id, token, opts \\ []) do
    max_items = Keyword.get(opts, :max_items, 200)
    fetch_page = fn page_opts -> get_artist_albums(artist_id, token, page_opts) end
    Pagination.fetch_all(fetch_page, opts, max_items)
  end

  @doc """
  Get Spotify catalog information about an artist's top tracks by market.
  https://developer.spotify.com/documentation/web-api/reference/get-an-artists-top-tracks
  """
  @spec get_artist_top_tracks(String.t(), String.t(), String.t()) :: any
  def get_artist_top_tracks(artist_id, token, market) do
    Client.get("/artists/#{artist_id}/top-tracks?market=#{market}", [], token)
  end
end
