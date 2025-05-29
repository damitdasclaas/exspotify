defmodule Exspotify.Structs.Followers do
  @moduledoc """
  Represents followers information from Spotify API.
  """

  defstruct [
    :href,
    :total
  ]

  @type t :: %__MODULE__{
    href: String.t() | nil,
    total: integer()
  }

  @doc """
  Creates a Followers struct from a map.
  """
  @spec from_map(map()) :: t()
  def from_map(map) when is_map(map) do
    %__MODULE__{
      href: Map.get(map, "href"),
      total: Map.get(map, "total", 0)
    }
  end
end
