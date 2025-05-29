defmodule Exspotify.Structs.Track do
  @moduledoc """
  Represents a track object from Spotify API.
  """

  alias Exspotify.Structs.{Album, Artist, ExternalUrls, ExternalIds}

  @enforce_keys [:id, :name, :type, :uri]
  defstruct [
    :id,
    :name,
    :type,
    :uri,
    :href,
    :album,
    :artists,
    :available_markets,
    :disc_number,
    :duration_ms,
    :explicit,
    :external_ids,
    :external_urls,
    :is_playable,
    :linked_from,
    :restrictions,
    :popularity,
    :preview_url,
    :track_number,
    :is_local
  ]

  @type t :: %__MODULE__{
    id: String.t(),
    name: String.t(),
    type: String.t(),
    uri: String.t(),
    href: String.t() | nil,
    album: Album.t() | nil,
    artists: [Artist.t()] | nil,
    available_markets: [String.t()] | nil,
    disc_number: integer() | nil,
    duration_ms: integer() | nil,
    explicit: boolean() | nil,
    external_ids: ExternalIds.t() | nil,
    external_urls: ExternalUrls.t() | nil,
    is_playable: boolean() | nil,
    linked_from: map() | nil,
    restrictions: map() | nil,
    popularity: integer() | nil,
    preview_url: String.t() | nil,
    track_number: integer() | nil,
    is_local: boolean() | nil
  }

  @doc """
  Creates a Track struct from a map (typically from JSON).
  """
  @spec from_map(map()) :: t()
  def from_map(map) when is_map(map) do
    %__MODULE__{
      id: Map.get(map, "id"),
      name: Map.get(map, "name"),
      type: Map.get(map, "type"),
      uri: Map.get(map, "uri"),
      href: Map.get(map, "href"),
      album: parse_album(Map.get(map, "album")),
      artists: parse_artists(Map.get(map, "artists")),
      available_markets: Map.get(map, "available_markets"),
      disc_number: Map.get(map, "disc_number"),
      duration_ms: Map.get(map, "duration_ms"),
      explicit: Map.get(map, "explicit"),
      external_ids: parse_external_ids(Map.get(map, "external_ids")),
      external_urls: parse_external_urls(Map.get(map, "external_urls")),
      is_playable: Map.get(map, "is_playable"),
      linked_from: Map.get(map, "linked_from"),
      restrictions: Map.get(map, "restrictions"),
      popularity: Map.get(map, "popularity"),
      preview_url: Map.get(map, "preview_url"),
      track_number: Map.get(map, "track_number"),
      is_local: Map.get(map, "is_local")
    }
  end

  defp parse_album(nil), do: nil
  defp parse_album(map), do: Album.from_map(map)

  defp parse_artists(nil), do: nil
  defp parse_artists(artists) when is_list(artists) do
    Enum.map(artists, &Artist.from_map/1)
  end

  defp parse_external_ids(nil), do: nil
  defp parse_external_ids(map), do: ExternalIds.from_map(map)

  defp parse_external_urls(nil), do: nil
  defp parse_external_urls(map), do: ExternalUrls.from_map(map)
end
