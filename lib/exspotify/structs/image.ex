defmodule Exspotify.Structs.Image do
  @moduledoc """
  Represents an image object from Spotify API.
  Used by albums, artists, playlists, users, shows, and audiobooks.
  """

  @enforce_keys [:url]
  defstruct [
    :url,
    :height,
    :width
  ]

  @type t :: %__MODULE__{
    url: String.t(),
    height: integer() | nil,
    width: integer() | nil
  }

  @doc """
  Creates an Image struct from a map (typically from JSON).
  """
  @spec from_map(map()) :: t()
  def from_map(map) when is_map(map) do
    %__MODULE__{
      url: Map.get(map, "url"),
      height: Map.get(map, "height"),
      width: Map.get(map, "width")
    }
  end
end
