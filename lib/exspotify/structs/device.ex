defmodule Exspotify.Structs.Device do
  @moduledoc """
  Represents a device object from Spotify API.
  Used for user's available playback devices.
  """

  @enforce_keys [:id, :name, :type]
  defstruct [
    :id,
    :name,
    :type,
    :is_active,
    :is_private_session,
    :is_restricted,
    :volume_percent,
    :supports_volume
  ]

  @type t :: %__MODULE__{
    id: String.t(),
    name: String.t(),
    type: String.t(),
    is_active: boolean() | nil,
    is_private_session: boolean() | nil,
    is_restricted: boolean() | nil,
    volume_percent: integer() | nil,
    supports_volume: boolean() | nil
  }

  @doc """
  Creates a Device struct from a map.
  """
  @spec from_map(map()) :: t()
  def from_map(map) when is_map(map) do
    %__MODULE__{
      id: Map.get(map, "id"),
      name: Map.get(map, "name"),
      type: Map.get(map, "type"),
      is_active: Map.get(map, "is_active"),
      is_private_session: Map.get(map, "is_private_session"),
      is_restricted: Map.get(map, "is_restricted"),
      volume_percent: Map.get(map, "volume_percent"),
      supports_volume: Map.get(map, "supports_volume")
    }
  end
end
