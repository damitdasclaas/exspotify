defmodule Exspotify.Structs.Actions do
  @moduledoc """
  Represents available playback actions from Spotify API.
  Used to indicate which playback actions are allowed.
  """

  defstruct [
    :interrupting_playback,
    :pausing,
    :resuming,
    :seeking,
    :skipping_next,
    :skipping_prev,
    :toggling_repeat_context,
    :toggling_shuffle,
    :toggling_repeat_track,
    :transferring_playback
  ]

  @type t :: %__MODULE__{
    interrupting_playback: boolean() | nil,
    pausing: boolean() | nil,
    resuming: boolean() | nil,
    seeking: boolean() | nil,
    skipping_next: boolean() | nil,
    skipping_prev: boolean() | nil,
    toggling_repeat_context: boolean() | nil,
    toggling_shuffle: boolean() | nil,
    toggling_repeat_track: boolean() | nil,
    transferring_playback: boolean() | nil
  }

  @doc """
  Creates an Actions struct from a map.
  """
  @spec from_map(map()) :: t()
  def from_map(map) when is_map(map) do
    %__MODULE__{
      interrupting_playback: Map.get(map, "interrupting_playback"),
      pausing: Map.get(map, "pausing"),
      resuming: Map.get(map, "resuming"),
      seeking: Map.get(map, "seeking"),
      skipping_next: Map.get(map, "skipping_next"),
      skipping_prev: Map.get(map, "skipping_prev"),
      toggling_repeat_context: Map.get(map, "toggling_repeat_context"),
      toggling_shuffle: Map.get(map, "toggling_shuffle"),
      toggling_repeat_track: Map.get(map, "toggling_repeat_track"),
      transferring_playback: Map.get(map, "transferring_playback")
    }
  end
end
