defmodule Exspotify.Structs.Show do
  @moduledoc """
  Represents a show (podcast) object from Spotify API.
  """

  alias Exspotify.Structs.{ExternalUrls, Image}

  @enforce_keys [:id, :name, :type, :uri]
  defstruct [
    :id,
    :name,
    :type,
    :uri,
    :href,
    :available_markets,
    :copyrights,
    :description,
    :html_description,
    :explicit,
    :external_urls,
    :images,
    :is_externally_hosted,
    :languages,
    :media_type,
    :publisher,
    :total_episodes,
    :episodes
  ]

  @type t :: %__MODULE__{
    id: String.t(),
    name: String.t(),
    type: String.t(),
    uri: String.t(),
    href: String.t() | nil,
    available_markets: [String.t()] | nil,
    copyrights: [map()] | nil,
    description: String.t() | nil,
    html_description: String.t() | nil,
    explicit: boolean() | nil,
    external_urls: ExternalUrls.t() | nil,
    images: [Image.t()] | nil,
    is_externally_hosted: boolean() | nil,
    languages: [String.t()] | nil,
    media_type: String.t() | nil,
    publisher: String.t() | nil,
    total_episodes: integer() | nil,
    episodes: map() | nil
  }

  @doc """
  Creates a Show struct from a map (typically from JSON).
  """
  @spec from_map(map()) :: t()
  def from_map(map) when is_map(map) do
    %__MODULE__{
      id: Map.get(map, "id") || "unknown",
      name: Map.get(map, "name") || "Untitled Show",
      type: Map.get(map, "type") || "show",
      uri: Map.get(map, "uri") || "",
      href: Map.get(map, "href"),
      available_markets: Map.get(map, "available_markets"),
      copyrights: Map.get(map, "copyrights"),
      description: Map.get(map, "description"),
      html_description: Map.get(map, "html_description"),
      explicit: Map.get(map, "explicit"),
      external_urls: parse_external_urls(Map.get(map, "external_urls")),
      images: parse_images(Map.get(map, "images")),
      is_externally_hosted: Map.get(map, "is_externally_hosted"),
      languages: Map.get(map, "languages"),
      media_type: Map.get(map, "media_type"),
      publisher: Map.get(map, "publisher"),
      total_episodes: Map.get(map, "total_episodes"),
      episodes: Map.get(map, "episodes")
    }
  end

  # Handle non-map inputs gracefully by returning nil
  def from_map(_), do: nil

  defp parse_external_urls(nil), do: nil
  defp parse_external_urls(map), do: ExternalUrls.from_map(map)

  defp parse_images(nil), do: nil
  defp parse_images(images) when is_list(images) do
    Enum.map(images, &Image.from_map/1)
  end
  defp parse_images(_), do: nil  # Handle invalid input gracefully
end
