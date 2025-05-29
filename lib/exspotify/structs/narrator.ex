defmodule Exspotify.Structs.Narrator do
  @moduledoc """
  Represents a narrator object from Spotify API.
  Used by audiobooks.
  """

  @enforce_keys [:name]
  defstruct [
    :name
  ]

  @type t :: %__MODULE__{
    name: String.t()
  }

  @doc """
  Creates a Narrator struct from a map.
  """
  @spec from_map(map()) :: t()
  def from_map(map) when is_map(map) do
    %__MODULE__{
      name: Map.get(map, "name")
    }
  end
end
