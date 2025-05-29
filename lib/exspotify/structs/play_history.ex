defmodule Exspotify.Structs.PlayHistory do
  @moduledoc """
  Represents a play history item from Spotify API.
  Used in recently played tracks response.
  """

  alias Exspotify.Structs.{Context, Track}

  @enforce_keys [:track, :played_at]
  defstruct [
    :track,
    :played_at,
    :context
  ]

  @type t :: %__MODULE__{
    track: Track.t(),
    played_at: String.t(),
    context: Context.t() | nil
  }

  @doc """
  Creates a PlayHistory struct from a map.
  """
  @spec from_map(map()) :: t()
  def from_map(map) when is_map(map) do
    %__MODULE__{
      track: parse_track(Map.get(map, "track")),
      played_at: Map.get(map, "played_at"),
      context: parse_context(Map.get(map, "context"))
    }
  end

  defp parse_track(nil), do: nil
  defp parse_track(map), do: Track.from_map(map)

  defp parse_context(nil), do: nil
  defp parse_context(map), do: Context.from_map(map)
end
