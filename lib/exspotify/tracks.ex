defmodule Exspotify.Tracks do
  @moduledoc """
  Provides functions for interacting with the Tracks endpoints of the Spotify Web API.
  Deprecated endpoints (audio features, audio analysis, recommendations) are not included.
  See: https://developer.spotify.com/documentation/web-api/reference/tracks
  """

  alias Exspotify.Client
  alias Exspotify.Pagination

  @doc """
  Get Spotify catalog information for a single track by its unique Spotify ID.
  https://developer.spotify.com/documentation/web-api/reference/get-track
  """
  @spec get_track(String.t(), String.t()) :: any
  def get_track(track_id, token) do
    Client.get("/tracks/#{track_id}", [], token)
  end

  @doc """
  Get Spotify catalog information for several tracks based on their Spotify IDs.
  https://developer.spotify.com/documentation/web-api/reference/get-several-tracks
  """
  @spec get_several_tracks([String.t()], String.t()) :: any
  def get_several_tracks(track_ids, token) when is_list(track_ids) do
    ids_param = Enum.join(track_ids, ",")
    Client.get("/tracks?ids=#{ids_param}", [], token)
  end

  @doc """
  Get a list of the tracks saved in the current Spotify user's library (paginated).
  https://developer.spotify.com/documentation/web-api/reference/get-users-saved-tracks
  """
  @spec get_users_saved_tracks(String.t(), keyword) :: any
  def get_users_saved_tracks(token, opts \\ []) do
    query = URI.encode_query(opts)
    path = "/me/tracks" <> if(query != "", do: "?#{query}", else: "")
    Client.get(path, [], token)
  end

  @doc """
  Fetches all saved tracks for the user, following all pages.

  **Warning:** This may make a large number of requests if the user has many saved tracks.
  You can limit the number of items fetched with the `:max_items` option (default: 200).
  """
  @spec get_all_users_saved_tracks(String.t(), keyword) :: [map]
  def get_all_users_saved_tracks(token, opts \\ []) do
    max_items = Keyword.get(opts, :max_items, 200)
    fetch_page = fn page_opts -> get_users_saved_tracks(token, page_opts) end
    Pagination.fetch_all(fetch_page, opts, max_items)
  end

  @doc """
  Save one or more tracks to the current user's library.
  https://developer.spotify.com/documentation/web-api/reference/save-tracks-user
  """
  @spec save_tracks_for_current_user([String.t()], String.t()) :: any
  def save_tracks_for_current_user(track_ids, token) when is_list(track_ids) do
    query = URI.encode_query(%{"ids" => Enum.join(track_ids, ",")})
    Client.put("/me/tracks?#{query}", %{}, [], token)
  end

  @doc """
  Remove one or more tracks from the current user's library.
  https://developer.spotify.com/documentation/web-api/reference/remove-tracks-user
  """
  @spec remove_users_saved_tracks([String.t()], String.t()) :: any
  def remove_users_saved_tracks(track_ids, token) when is_list(track_ids) do
    query = URI.encode_query(%{"ids" => Enum.join(track_ids, ",")})
    Client.delete("/me/tracks?#{query}", [], token)
  end

  @doc """
  Check if one or more tracks are saved in the current user's library.
  https://developer.spotify.com/documentation/web-api/reference/check-users-saved-tracks
  """
  @spec check_users_saved_tracks([String.t()], String.t()) :: any
  def check_users_saved_tracks(track_ids, token) when is_list(track_ids) do
    query = URI.encode_query(%{"ids" => Enum.join(track_ids, ",")})
    Client.get("/me/tracks/contains?#{query}", [], token)
  end
end
