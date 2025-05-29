defmodule Exspotify.Structs.Context do
  @moduledoc """
  Represents a context object from Spotify API.
  Used for playback context (album, playlist, artist, etc.).
  """

  alias Exspotify.Structs.ExternalUrls

  @enforce_keys [:type, :uri]
  defstruct [
    :type,
    :uri,
    :href,
    :external_urls
  ]

  @type t :: %__MODULE__{
    type: String.t(),
    uri: String.t(),
    href: String.t() | nil,
    external_urls: ExternalUrls.t() | nil
  }

  @doc """
  Creates a Context struct from a map.
  """
  @spec from_map(map()) :: t()
  def from_map(map) when is_map(map) do
    %__MODULE__{
      type: Map.get(map, "type"),
      uri: Map.get(map, "uri"),
      href: Map.get(map, "href"),
      external_urls: parse_external_urls(Map.get(map, "external_urls"))
    }
  end

  defp parse_external_urls(nil), do: nil
  defp parse_external_urls(map), do: ExternalUrls.from_map(map)
end
