defmodule Exspotify.Structs.Artist do
  @moduledoc """
  Represents an artist object from Spotify API.
  """

  alias Exspotify.Structs.{ExternalUrls, Followers, Image}

  @enforce_keys [:id, :name, :type, :uri]
  defstruct [
    :id,
    :name,
    :type,
    :uri,
    :href,
    :external_urls,
    :followers,
    :genres,
    :images,
    :popularity
  ]

  @type t :: %__MODULE__{
    id: String.t(),
    name: String.t(),
    type: String.t(),
    uri: String.t(),
    href: String.t() | nil,
    external_urls: ExternalUrls.t() | nil,
    followers: Followers.t() | nil,
    genres: [String.t()] | nil,
    images: [Image.t()] | nil,
    popularity: integer() | nil
  }

  @doc """
  Creates an Artist struct from a map (typically from JSON).
  """
  @spec from_map(map()) :: t()
  def from_map(map) when is_map(map) do
    # Validate required fields
    unless map["id"] && map["name"] && map["type"] && map["uri"] do
      raise ArgumentError, "Artist missing required fields: id, name, type, or uri"
    end

    %__MODULE__{
      id: Map.get(map, "id"),
      name: Map.get(map, "name"),
      type: Map.get(map, "type"),
      uri: Map.get(map, "uri"),
      href: Map.get(map, "href"),
      external_urls: parse_external_urls(Map.get(map, "external_urls")),
      followers: parse_followers(Map.get(map, "followers")),
      genres: Map.get(map, "genres"),
      images: parse_images(Map.get(map, "images")),
      popularity: validate_integer(Map.get(map, "popularity"))
    }
  end

  defp parse_external_urls(nil), do: nil
  defp parse_external_urls(map), do: ExternalUrls.from_map(map)

  defp parse_followers(nil), do: nil
  defp parse_followers(map), do: Followers.from_map(map)

  defp parse_images(nil), do: nil
  defp parse_images(images) when is_list(images) do
    Enum.map(images, &Image.from_map/1)
  end
  defp parse_images(_), do: nil  # Handle invalid input gracefully

  # Validates that a value is an integer or nil
  defp validate_integer(nil), do: nil
  defp validate_integer(value) when is_integer(value), do: value
  defp validate_integer(_), do: nil  # Convert invalid types to nil
end
