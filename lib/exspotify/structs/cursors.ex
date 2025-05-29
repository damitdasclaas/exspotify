defmodule Exspotify.Structs.Cursors do
  @moduledoc """
  Represents cursor-based pagination from Spotify API.
  Used in recently played tracks and other cursor-paginated endpoints.
  """

  defstruct [
    :after,
    :before
  ]

  @type t :: %__MODULE__{
    after: String.t() | nil,
    before: String.t() | nil
  }

  @doc """
  Creates a Cursors struct from a map.
  """
  @spec from_map(map()) :: t()
  def from_map(map) when is_map(map) do
    %__MODULE__{
      after: Map.get(map, "after"),
      before: Map.get(map, "before")
    }
  end
end
