defmodule Exspotify.Structs.Queue do
  @moduledoc """
  Represents the user's playback queue from Spotify API.
  """

  alias Exspotify.Structs.{Track, Episode}

  defstruct [
    :currently_playing,
    :queue
  ]

  @type t :: %__MODULE__{
    currently_playing: Track.t() | Episode.t() | nil,
    queue: [Track.t() | Episode.t()] | nil
  }

  @doc """
  Creates a Queue struct from a map.
  """
  @spec from_map(map()) :: t()
  def from_map(map) when is_map(map) do
    %__MODULE__{
      currently_playing: parse_item(Map.get(map, "currently_playing")),
      queue: parse_queue(Map.get(map, "queue"))
    }
  end

  defp parse_item(nil), do: nil
  defp parse_item(%{"type" => "track"} = map), do: Track.from_map(map)
  defp parse_item(%{"type" => "episode"} = map), do: Episode.from_map(map)
  defp parse_item(map), do: Track.from_map(map) # Default to track for backwards compatibility

  defp parse_queue(nil), do: nil
  defp parse_queue(queue) when is_list(queue) do
    Enum.map(queue, &parse_item/1)
  end
end
