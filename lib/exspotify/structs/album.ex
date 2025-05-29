defmodule Exspotify.Structs.Album do
  @moduledoc """
  Represents an album object from Spotify API.
  """

  alias Exspotify.Structs.{Artist, ExternalUrls, ExternalIds, Image}

  @enforce_keys [:id, :name, :type, :uri]
  defstruct [
    :id,
    :name,
    :type,
    :uri,
    :href,
    :album_type,
    :total_tracks,
    :available_markets,
    :external_urls,
    :external_ids,
    :images,
    :release_date,
    :release_date_precision,
    :artists,
    :genres,
    :label,
    :popularity,
    :copyrights,
    :restrictions,
    :tracks
  ]

  @type t :: %__MODULE__{
    id: String.t(),
    name: String.t(),
    type: String.t(),
    uri: String.t(),
    href: String.t() | nil,
    album_type: String.t() | nil,
    total_tracks: integer() | nil,
    available_markets: [String.t()] | nil,
    external_urls: ExternalUrls.t() | nil,
    external_ids: ExternalIds.t() | nil,
    images: [Image.t()] | nil,
    release_date: String.t() | nil,
    release_date_precision: String.t() | nil,
    artists: [Artist.t()] | nil,
    genres: [String.t()] | nil,
    label: String.t() | nil,
    popularity: integer() | nil,
    copyrights: [map()] | nil,
    restrictions: map() | nil,
    tracks: map() | nil
  }

  @doc """
  Creates an Album struct from a map (typically from JSON).
  """
  @spec from_map(map()) :: t()
  def from_map(map) when is_map(map) do
    %__MODULE__{
      id: Map.get(map, "id"),
      name: Map.get(map, "name"),
      type: Map.get(map, "type"),
      uri: Map.get(map, "uri"),
      href: Map.get(map, "href"),
      album_type: Map.get(map, "album_type"),
      total_tracks: Map.get(map, "total_tracks"),
      available_markets: Map.get(map, "available_markets"),
      external_urls: parse_external_urls(Map.get(map, "external_urls")),
      external_ids: parse_external_ids(Map.get(map, "external_ids")),
      images: parse_images(Map.get(map, "images")),
      release_date: Map.get(map, "release_date"),
      release_date_precision: Map.get(map, "release_date_precision"),
      artists: parse_artists(Map.get(map, "artists")),
      genres: Map.get(map, "genres"),
      label: Map.get(map, "label"),
      popularity: Map.get(map, "popularity"),
      copyrights: Map.get(map, "copyrights"),
      restrictions: Map.get(map, "restrictions"),
      tracks: Map.get(map, "tracks")
    }
  end

  defp parse_external_urls(nil), do: nil
  defp parse_external_urls(map), do: ExternalUrls.from_map(map)

  defp parse_external_ids(nil), do: nil
  defp parse_external_ids(map), do: ExternalIds.from_map(map)

  defp parse_images(nil), do: nil
  defp parse_images(images) when is_list(images) do
    Enum.map(images, &Image.from_map/1)
  end

  defp parse_artists(nil), do: nil
  defp parse_artists(artists) when is_list(artists) do
    Enum.map(artists, &Artist.from_map/1)
  end
end
