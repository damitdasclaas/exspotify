defmodule Exspotify.Search do
  @moduledoc """
  Provides functions for interacting with the Search endpoints of the Spotify Web API.
  See: https://developer.spotify.com/documentation/web-api/reference/search
  """

  alias Exspotify.{Client, Error}
  alias Exspotify.Structs.{Album, Artist, Track, Playlist, Show, Episode, Audiobook, Paging}

  @doc """
  Search for items (albums, artists, tracks, playlists, shows, episodes, audiobooks).
  Returns a map with keys corresponding to the types searched, each containing a Paging struct.

  type can be a comma-separated string like "album,artist,track" or a list like ["album", "artist", "track"]
  """
  @spec search(String.t(), String.t() | [String.t()], String.t(), keyword) :: {:ok, map()} | {:error, Error.t()}
  def search(query, type, token, opts \\ []) do
    with :ok <- validate_search_query(query),
         :ok <- Error.validate_token(token),
         :ok <- validate_search_types(type) do
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
        {:error, error} -> {:error, error}
      end
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

  # Private helper to validate search query
  defp validate_search_query(query) when is_binary(query) and byte_size(query) > 0, do: :ok
  defp validate_search_query(query) do
    {:error, Error.new(:invalid_id, "Search query must be a non-empty string, got: #{inspect(query)}", %{field: "query", value: query})}
  end

  # Private helper to validate search types
  defp validate_search_types(types) when is_list(types) do
    valid_types = ["album", "artist", "track", "playlist", "show", "episode", "audiobook"]

    case Enum.find(types, &(&1 not in valid_types)) do
      nil ->
        if Enum.empty?(types) do
          {:error, Error.new(:empty_list, "Search types cannot be empty", %{field: "type"})}
        else
          :ok
        end
      invalid_type ->
        {:error, Error.new(:invalid_type, "Invalid search type: #{inspect(invalid_type)}", %{field: "type", value: invalid_type, valid_types: valid_types})}
    end
  end

  defp validate_search_types(types) when is_binary(types) do
    # Convert string to list and validate
    type_list = String.split(types, ",", trim: true)
    validate_search_types(type_list)
  end

  defp validate_search_types(types) do
    {:error, Error.new(:invalid_type, "Search types must be a string or list, got: #{inspect(types)}", %{field: "type", value: types})}
  end
end
