defmodule Exspotify.Structs.Paging do
  @moduledoc """
  Represents Spotify's standard paging object used for paginated responses.

  This structure is used across many endpoints that return lists of items with pagination support.
  """

  @enforce_keys [:limit, :offset, :total, :items]
  defstruct [
    :href,
    :limit,
    :next,
    :offset,
    :previous,
    :total,
    :items
  ]

  @type t :: %__MODULE__{
          href: String.t() | nil,
          limit: non_neg_integer(),
          next: String.t() | nil,
          offset: non_neg_integer(),
          previous: String.t() | nil,
          total: non_neg_integer(),
          items: list(any())
        }

  @doc """
  Creates a Paging struct from a map, with support for parsing items using a custom parser function.

  ## Parameters
  - `map`: The raw map from the API response
  - `item_parser`: A function that takes a map and returns a parsed item (optional)

  ## Examples
      iex> from_map(%{"limit" => 20, "offset" => 0, "total" => 100, "items" => []})
      %Paging{limit: 20, offset: 0, total: 100, items: []}

      iex> from_map(%{"limit" => 20, "offset" => 0, "total" => 100, "items" => [%{"id" => "123"}]}, fn item -> item["id"] end)
      %Paging{limit: 20, offset: 0, total: 100, items: ["123"]}
  """
  def from_map(map, item_parser \\ & &1) when is_map(map) do
    %__MODULE__{
      href: map["href"],
      limit: map["limit"],
      next: map["next"],
      offset: map["offset"],
      previous: map["previous"],
      total: map["total"],
      items: parse_items(map["items"], item_parser)
    }
  end

  defp parse_items(nil, _parser), do: []
  defp parse_items(items, parser) when is_list(items) do
    Enum.map(items, parser)
  end
end
