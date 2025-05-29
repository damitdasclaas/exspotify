defmodule Exspotify.Structs.ExternalIds do
  @moduledoc """
  Represents external IDs object from Spotify API.
  Contains various external identifiers like ISRC, EAN, UPC.
  """

  defstruct [
    :isrc,
    :ean,
    :upc
  ]

  @type t :: %__MODULE__{
    isrc: String.t() | nil,
    ean: String.t() | nil,
    upc: String.t() | nil
  }

  @doc """
  Creates an ExternalIds struct from a map.
  """
  @spec from_map(map()) :: t()
  def from_map(map) when is_map(map) do
    %__MODULE__{
      isrc: Map.get(map, "isrc"),
      ean: Map.get(map, "ean"),
      upc: Map.get(map, "upc")
    }
  end
end
