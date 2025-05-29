defmodule Exspotify.Structs.User do
  @moduledoc """
  Represents a user object from Spotify API.
  """

  alias Exspotify.Structs.{ExternalUrls, Followers, Image}

  @enforce_keys [:id, :type, :uri]
  defstruct [
    :id,
    :type,
    :uri,
    :href,
    :display_name,
    :country,
    :email,
    :explicit_content,
    :external_urls,
    :followers,
    :images,
    :product
  ]

  @type t :: %__MODULE__{
    id: String.t(),
    type: String.t(),
    uri: String.t(),
    href: String.t() | nil,
    display_name: String.t() | nil,
    country: String.t() | nil,
    email: String.t() | nil,
    explicit_content: map() | nil,
    external_urls: ExternalUrls.t() | nil,
    followers: Followers.t() | nil,
    images: [Image.t()] | nil,
    product: String.t() | nil
  }

  @doc """
  Creates a User struct from a map (typically from JSON).
  """
  @spec from_map(map()) :: t()
  def from_map(map) when is_map(map) do
    %__MODULE__{
      id: Map.get(map, "id") || "unknown",
      type: Map.get(map, "type") || "user",
      uri: Map.get(map, "uri") || "",
      href: Map.get(map, "href"),
      display_name: Map.get(map, "display_name"),
      country: Map.get(map, "country"),
      email: Map.get(map, "email"),
      explicit_content: Map.get(map, "explicit_content"),
      external_urls: parse_external_urls(Map.get(map, "external_urls")),
      followers: parse_followers(Map.get(map, "followers")),
      images: parse_images(Map.get(map, "images")),
      product: Map.get(map, "product")
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
end
