defmodule Exspotify.Structs.ResumePoint do
  @moduledoc """
  Represents a resume point object from Spotify API.
  Used by episodes and chapters to track playback position.
  """

  defstruct [
    :fully_played,
    :resume_position_ms
  ]

  @type t :: %__MODULE__{
    fully_played: boolean() | nil,
    resume_position_ms: integer() | nil
  }

  @doc """
  Creates a ResumePoint struct from a map.
  """
  @spec from_map(map()) :: t()
  def from_map(map) when is_map(map) do
    %__MODULE__{
      fully_played: Map.get(map, "fully_played"),
      resume_position_ms: Map.get(map, "resume_position_ms")
    }
  end
end
