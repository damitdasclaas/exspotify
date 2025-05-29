defmodule Exspotify.Structs.Playlist do
  @moduledoc """
  Represents a playlist object from Spotify API.
  """

  alias Exspotify.Structs.{ExternalUrls, Image, User}

  @enforce_keys [:id, :name, :type, :uri]
  defstruct [
    :id,
    :name,
    :type,
    :uri,
    :href,
    :collaborative,
    :description,
    :external_urls,
    :images,
    :owner,
    :public,
    :snapshot_id,
    :tracks
  ]

  @type t :: %__MODULE__{
    id: String.t(),
    name: String.t(),
    type: String.t(),
    uri: String.t(),
    href: String.t() | nil,
    collaborative: boolean() | nil,
    description: String.t() | nil,
    external_urls: ExternalUrls.t() | nil,
    images: [Image.t()] | nil,
    owner: User.t() | nil,
    public: boolean() | nil,
    snapshot_id: String.t() | nil,
    tracks: map() | nil
  }

  @doc """
  Creates a Playlist struct from a map (typically from JSON).
  """
  @spec from_map(map()) :: t()
  def from_map(map) when is_map(map) do
    %__MODULE__{
      id: Map.get(map, "id") || "unknown",
      name: Map.get(map, "name") || "Untitled Playlist",
      type: Map.get(map, "type") || "playlist",
      uri: Map.get(map, "uri") || "",
      href: Map.get(map, "href"),
      collaborative: Map.get(map, "collaborative"),
      description: Map.get(map, "description"),
      external_urls: parse_external_urls(Map.get(map, "external_urls")),
      images: parse_images(Map.get(map, "images")),
      owner: parse_owner(Map.get(map, "owner")),
      public: Map.get(map, "public"),
      snapshot_id: Map.get(map, "snapshot_id"),
      tracks: Map.get(map, "tracks")
    }
  end

  defp parse_external_urls(nil), do: nil
  defp parse_external_urls(map), do: ExternalUrls.from_map(map)

  defp parse_images(nil), do: nil
  defp parse_images(images) when is_list(images) do
    Enum.map(images, &Image.from_map/1)
  end
  defp parse_images(_), do: nil  # Handle invalid input gracefully

  defp parse_owner(nil), do: nil
  defp parse_owner(map), do: User.from_map(map)
end
