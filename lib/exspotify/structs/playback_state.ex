defmodule Exspotify.Structs.PlaybackState do
  @moduledoc """
  Represents the current playback state from Spotify API.
  Contains information about the device, track, context, and playback controls.
  """

  alias Exspotify.Structs.{Actions, Context, Device, Track, Episode}

  defstruct [
    :device,
    :repeat_state,
    :shuffle_state,
    :context,
    :timestamp,
    :progress_ms,
    :is_playing,
    :item,
    :currently_playing_type,
    :actions
  ]

  @type t :: %__MODULE__{
    device: Device.t() | nil,
    repeat_state: String.t() | nil,
    shuffle_state: boolean() | nil,
    context: Context.t() | nil,
    timestamp: integer() | nil,
    progress_ms: integer() | nil,
    is_playing: boolean() | nil,
    item: Track.t() | Episode.t() | nil,
    currently_playing_type: String.t() | nil,
    actions: Actions.t() | nil
  }

  @doc """
  Creates a PlaybackState struct from a map.
  """
  @spec from_map(map()) :: t()
  def from_map(map) when is_map(map) do
    %__MODULE__{
      device: parse_device(Map.get(map, "device")),
      repeat_state: Map.get(map, "repeat_state"),
      shuffle_state: Map.get(map, "shuffle_state"),
      context: parse_context(Map.get(map, "context")),
      timestamp: Map.get(map, "timestamp"),
      progress_ms: Map.get(map, "progress_ms"),
      is_playing: Map.get(map, "is_playing"),
      item: parse_item(Map.get(map, "item")),
      currently_playing_type: Map.get(map, "currently_playing_type"),
      actions: parse_actions(Map.get(map, "actions"))
    }
  end

  defp parse_device(nil), do: nil
  defp parse_device(map), do: Device.from_map(map)

  defp parse_context(nil), do: nil
  defp parse_context(map), do: Context.from_map(map)

  defp parse_actions(nil), do: nil
  defp parse_actions(map), do: Actions.from_map(map)

  defp parse_item(nil), do: nil
  defp parse_item(%{"type" => "track"} = map), do: Track.from_map(map)
  defp parse_item(%{"type" => "episode"} = map), do: Episode.from_map(map)
  defp parse_item(map), do: Track.from_map(map) # Default to track for backwards compatibility
end
