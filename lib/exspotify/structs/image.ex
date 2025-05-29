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
      url: Map.get(map, "url") || "",
      height: validate_integer(Map.get(map, "height")),
      width: validate_integer(Map.get(map, "width"))
    }
  end

  # Validates that a value is an integer or nil
  defp validate_integer(nil), do: nil
  defp validate_integer(value) when is_integer(value), do: value
  defp validate_integer(_), do: nil  # Convert invalid types to nil
end
