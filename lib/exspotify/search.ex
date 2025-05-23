defmodule Exspotify.Search do
  @moduledoc """
  Provides functions for searching Spotify content (tracks, artists, albums, playlists, shows, episodes, audiobooks).
  See: https://developer.spotify.com/documentation/web-api/reference/search
  """

  alias Exspotify.Client

  @doc """
  Search for items in the Spotify catalog.

  Supported types: "album", "artist", "playlist", "track", "show", "episode", "audiobook"
  Options can include: limit, offset, market, include_external, etc.
  https://developer.spotify.com/documentation/web-api/reference/search
  """
  @spec search(String.t(), [String.t()] | String.t(), String.t(), keyword) :: any
  def search(query, types, token, opts \\ []) do
    type_param =
      case types do
        t when is_list(t) -> Enum.join(t, ",")
        t when is_binary(t) -> t
      end
    params = Keyword.merge([q: query, type: type_param], opts)
    query_str = URI.encode_query(params)
    path = "/search?#{query_str}"
    Client.get(path, [], token)
  end
end
