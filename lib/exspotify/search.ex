defmodule Exspotify.Search do
  @moduledoc """
  Provides functions for interacting with the Search endpoints of the Spotify Web API.
  See: https://developer.spotify.com/documentation/web-api/reference/search
  """

  alias Exspotify.Client
  alias Exspotify.Structs.{Album, Artist, Track, Playlist, Show, Episode, Audiobook, Paging}

  @doc """
  Search for items (albums, artists, tracks, playlists, shows, episodes, audiobooks).
  Returns a map with keys corresponding to the types searched, each containing a Paging struct.

  type can be a comma-separated string like "album,artist,track" or a list like ["album", "artist", "track"]
  """
  @spec search(String.t(), String.t() | [String.t()], String.t(), keyword) :: {:ok, map()} | {:error, any()}
  def search(query, type, token, opts \\ []) do
    type_string = case type do
      list when is_list(list) -> Enum.join(list, ",")
      string when is_binary(string) -> string
    end

    query_params = [{"q", query}, {"type", type_string} | Enum.to_list(opts)]
    query_string = URI.encode_query(query_params)

    case Client.get("/search?#{query_string}", [], token) do
      {:ok, search_results} ->
        parsed_results = parse_search_results(search_results)
        {:ok, parsed_results}
      error -> error
    end
  end

  # Parse search results based on what's available in the response
  defp parse_search_results(results) do
    Map.new(results, fn {key, value} ->
      case key do
        "albums" -> {key, Paging.from_map(value, &Album.from_map/1)}
        "artists" -> {key, Paging.from_map(value, &Artist.from_map/1)}
        "tracks" -> {key, Paging.from_map(value, &Track.from_map/1)}
        "playlists" -> {key, Paging.from_map(value, &Playlist.from_map/1)}
        "shows" -> {key, Paging.from_map(value, &Show.from_map/1)}
        "episodes" -> {key, Paging.from_map(value, &Episode.from_map/1)}
        "audiobooks" -> {key, Paging.from_map(value, &Audiobook.from_map/1)}
        _ -> {key, value}  # fallback for unknown types
      end
    end)
  end
end
