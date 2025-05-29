defmodule Exspotify.Structs.ExternalUrls do
  @moduledoc """
  Represents external URLs object from Spotify API.
  Currently only contains Spotify URLs.
  """

  defstruct [
    :spotify
  ]

  @type t :: %__MODULE__{
    spotify: String.t() | nil
  }

  @doc """
  Creates an ExternalUrls struct from a map.
  """
  @spec from_map(map()) :: t()
  def from_map(map) when is_map(map) do
    %__MODULE__{
      spotify: Map.get(map, "spotify")
    }
  end
end
