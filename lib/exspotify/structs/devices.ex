defmodule Exspotify.Structs.Devices do
  @moduledoc """
  Represents the available devices response from Spotify API.
  """

  alias Exspotify.Structs.Device

  defstruct [
    :devices
  ]

  @type t :: %__MODULE__{
    devices: [Device.t()] | nil
  }

  @doc """
  Creates a Devices struct from a map.
  """
  @spec from_map(map()) :: t()
  def from_map(map) when is_map(map) do
    %__MODULE__{
      devices: parse_devices(Map.get(map, "devices"))
    }
  end

  defp parse_devices(nil), do: nil
  defp parse_devices(devices) when is_list(devices) do
    Enum.map(devices, &Device.from_map/1)
  end
end
