defmodule Exspotify.Structs.RecentlyPlayed do
  @moduledoc """
  Represents the recently played tracks response from Spotify API.
  """

  alias Exspotify.Structs.{Cursors, PlayHistory}

  defstruct [
    :href,
    :limit,
    :next,
    :cursors,
    :total,
    :items
  ]

  @type t :: %__MODULE__{
    href: String.t() | nil,
    limit: integer() | nil,
    next: String.t() | nil,
    cursors: Cursors.t() | nil,
    total: integer() | nil,
    items: [PlayHistory.t()] | nil
  }

  @doc """
  Creates a RecentlyPlayed struct from a map.
  """
  @spec from_map(map()) :: t()
  def from_map(map) when is_map(map) do
    %__MODULE__{
      href: Map.get(map, "href"),
      limit: Map.get(map, "limit"),
      next: Map.get(map, "next"),
      cursors: parse_cursors(Map.get(map, "cursors")),
      total: Map.get(map, "total"),
      items: parse_items(Map.get(map, "items"))
    }
  end

  defp parse_cursors(nil), do: nil
  defp parse_cursors(map), do: Cursors.from_map(map)

  defp parse_items(nil), do: nil
  defp parse_items(items) when is_list(items) do
    Enum.map(items, &PlayHistory.from_map/1)
  end
end
