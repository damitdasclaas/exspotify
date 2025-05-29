defmodule Exspotify.Structs.Audiobook do
  @moduledoc """
  Represents an audiobook object from Spotify API.
  """

  alias Exspotify.Structs.{Author, ExternalUrls, Image, Narrator}

  @enforce_keys [:id, :name, :type, :uri]
  defstruct [
    :id,
    :name,
    :type,
    :uri,
    :href,
    :authors,
    :available_markets,
    :copyrights,
    :description,
    :html_description,
    :edition,
    :explicit,
    :external_urls,
    :images,
    :languages,
    :media_type,
    :narrators,
    :publisher,
    :total_chapters,
    :chapters
  ]

  @type t :: %__MODULE__{
    id: String.t(),
    name: String.t(),
    type: String.t(),
    uri: String.t(),
    href: String.t() | nil,
    authors: [Author.t()] | nil,
    available_markets: [String.t()] | nil,
    copyrights: [map()] | nil,
    description: String.t() | nil,
    html_description: String.t() | nil,
    edition: String.t() | nil,
    explicit: boolean() | nil,
    external_urls: ExternalUrls.t() | nil,
    images: [Image.t()] | nil,
    languages: [String.t()] | nil,
    media_type: String.t() | nil,
    narrators: [Narrator.t()] | nil,
    publisher: String.t() | nil,
    total_chapters: integer() | nil,
    chapters: map() | nil
  }

  @doc """
  Creates an Audiobook struct from a map (typically from JSON).
  """
  @spec from_map(map()) :: t()
  def from_map(map) when is_map(map) do
    %__MODULE__{
      id: Map.get(map, "id"),
      name: Map.get(map, "name"),
      type: Map.get(map, "type"),
      uri: Map.get(map, "uri"),
      href: Map.get(map, "href"),
      authors: parse_authors(Map.get(map, "authors")),
      available_markets: Map.get(map, "available_markets"),
      copyrights: Map.get(map, "copyrights"),
      description: Map.get(map, "description"),
      html_description: Map.get(map, "html_description"),
      edition: Map.get(map, "edition"),
      explicit: Map.get(map, "explicit"),
      external_urls: parse_external_urls(Map.get(map, "external_urls")),
      images: parse_images(Map.get(map, "images")),
      languages: Map.get(map, "languages"),
      media_type: Map.get(map, "media_type"),
      narrators: parse_narrators(Map.get(map, "narrators")),
      publisher: Map.get(map, "publisher"),
      total_chapters: Map.get(map, "total_chapters"),
      chapters: Map.get(map, "chapters")
    }
  end

  defp parse_authors(nil), do: nil
  defp parse_authors(authors) when is_list(authors) do
    Enum.map(authors, &Author.from_map/1)
  end

  defp parse_external_urls(nil), do: nil
  defp parse_external_urls(map), do: ExternalUrls.from_map(map)

  defp parse_images(nil), do: nil
  defp parse_images(images) when is_list(images) do
    Enum.map(images, &Image.from_map/1)
  end

  defp parse_narrators(nil), do: nil
  defp parse_narrators(narrators) when is_list(narrators) do
    Enum.map(narrators, &Narrator.from_map/1)
  end
end
