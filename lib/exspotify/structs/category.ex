defmodule Exspotify.Structs.Category do
  @moduledoc """
  Represents a Spotify category object.

  A category in Spotify is used to tag items and help organize content.
  """

  alias Exspotify.Structs.Image

  @type t :: %__MODULE__{
    href: String.t() | nil,
    icons: [Image.t()],
    id: String.t(),
    name: String.t()
  }

  @enforce_keys [:id, :name]
  defstruct [
    :href,
    :icons,
    :id,
    :name
  ]

  @doc """
  Creates a Category struct from a map (typically from JSON API response).
  """
  @spec from_map(map()) :: t()
  def from_map(category_map) when is_map(category_map) do
    %__MODULE__{
      href: category_map["href"],
      icons: parse_icons(category_map["icons"]),
      id: category_map["id"],
      name: category_map["name"]
    }
  end

  # Parse icons array into Image structs
  defp parse_icons(nil), do: []
  defp parse_icons(icons) when is_list(icons) do
    Enum.map(icons, &Image.from_map/1)
  end
  defp parse_icons(_), do: []
end
