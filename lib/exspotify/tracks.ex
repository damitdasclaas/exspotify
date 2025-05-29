defmodule Exspotify.Tracks do
  @moduledoc """
  Provides functions for interacting with the Tracks endpoints of the Spotify Web API.
  Deprecated endpoints (audio features, audio analysis, recommendations) are not included.
  See: https://developer.spotify.com/documentation/web-api/reference/tracks
  """

  alias Exspotify.Client
  alias Exspotify.Structs.{Track, Paging}

  @doc """
  Get Spotify catalog information for a single track by its unique Spotify ID.
  https://developer.spotify.com/documentation/web-api/reference/get-track
  """
  @spec get_track(String.t(), String.t()) :: {:ok, Track.t()} | {:error, any()}
  def get_track(track_id, token) do
    case Client.get("/tracks/#{track_id}", [], token) do
      {:ok, track_map} -> {:ok, Track.from_map(track_map)}
      error -> error
    end
  end

  @doc """
  Get Spotify catalog information for several tracks based on their Spotify IDs.
  https://developer.spotify.com/documentation/web-api/reference/get-several-tracks
  """
  @spec get_several_tracks([String.t()], String.t()) :: {:ok, [Track.t()]} | {:error, any()}
  def get_several_tracks(track_ids, token) when is_list(track_ids) do
    ids_param = Enum.join(track_ids, ",")
    case Client.get("/tracks?ids=#{ids_param}", [], token) do
      {:ok, %{"tracks" => tracks_list}} ->
        tracks = Enum.map(tracks_list, &Track.from_map/1)
        {:ok, tracks}
      error -> error
    end
  end

  @doc """
  Get a list of the tracks saved in the current Spotify user's library (paginated).
  Returns a Paging struct containing saved tracks with added_at timestamps.
  https://developer.spotify.com/documentation/web-api/reference/get-users-saved-tracks
  """
  @spec get_users_saved_tracks(String.t(), keyword) :: {:ok, Paging.t()} | {:error, any()}
  def get_users_saved_tracks(token, opts \\ []) do
    query = URI.encode_query(opts)
    path = "/me/tracks" <> if(query != "", do: "?#{query}", else: "")
    case Client.get(path, [], token) do
      {:ok, paging_map} ->
        # Parse items as maps with added_at and track fields (we removed SavedTrack struct)
        parsed_paging = Paging.from_map(paging_map, fn item ->
          %{
            "added_at" => item["added_at"],
            "track" => Track.from_map(item["track"])
          }
        end)
        {:ok, parsed_paging}
      error -> error
    end
  end

  @doc """
  Save one or more tracks to the current user's library.
  https://developer.spotify.com/documentation/web-api/reference/save-tracks-user
  """
  @spec save_tracks_for_current_user([String.t()], String.t()) :: {:ok, any()} | {:error, any()}
  def save_tracks_for_current_user(track_ids, token) when is_list(track_ids) do
    query = URI.encode_query(%{"ids" => Enum.join(track_ids, ",")})
    Client.put("/me/tracks?#{query}", %{}, [], token)
  end

  @doc """
  Remove one or more tracks from the current user's library.
  https://developer.spotify.com/documentation/web-api/reference/remove-tracks-user
  """
  @spec remove_users_saved_tracks([String.t()], String.t()) :: {:ok, any()} | {:error, any()}
  def remove_users_saved_tracks(track_ids, token) when is_list(track_ids) do
    query = URI.encode_query(%{"ids" => Enum.join(track_ids, ",")})
    Client.delete("/me/tracks?#{query}", [], token)
  end

  @doc """
  Check if one or more tracks are saved in the current user's library.
  Returns a list of booleans corresponding to the track IDs.
  https://developer.spotify.com/documentation/web-api/reference/check-users-saved-tracks
  """
  @spec check_users_saved_tracks([String.t()], String.t()) :: {:ok, [boolean()]} | {:error, any()}
  def check_users_saved_tracks(track_ids, token) when is_list(track_ids) do
    query = URI.encode_query(%{"ids" => Enum.join(track_ids, ",")})
    Client.get("/me/tracks/contains?#{query}", [], token)
  end
end
