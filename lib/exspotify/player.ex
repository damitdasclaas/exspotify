defmodule Exspotify.Player do
  @moduledoc """
  Provides functions for interacting with the Player endpoints of the Spotify Web API.
  **Most endpoints require a user access token with appropriate scopes and an active device.**
  See: https://developer.spotify.com/documentation/web-api/reference/player
  """

  alias Exspotify.Client
  alias Exspotify.Structs.{PlaybackState, Devices, Queue, RecentlyPlayed}

  @doc """
  Get information about the user's current playback state.
  Requires: user-read-playback-state scope.
  """
  @spec get_playback_state(String.t()) :: {:ok, PlaybackState.t() | nil} | {:error, any()}
  def get_playback_state(token) do
    case Client.get("/me/player", [], token) do
      {:ok, nil} -> {:ok, nil}  # No active device
      {:ok, %{} = playback_map} -> {:ok, PlaybackState.from_map(playback_map)}
      error -> error
    end
  end

  @doc """
  Transfer playback to a new device.
  **Warning:** This will change the user's active playback device.
  Requires: user-modify-playback-state scope.
  """
  @spec transfer_playback(String.t(), [String.t()]) :: {:ok, any()} | {:error, any()}
  def transfer_playback(token, device_ids) when is_list(device_ids) do
    body = %{device_ids: device_ids}
    Client.put("/me/player", body, [], token)
  end

  @doc """
  Get a list of the user's available devices.
  Requires: user-read-playback-state scope.
  """
  @spec get_available_devices(String.t()) :: {:ok, Devices.t()} | {:error, any()}
  def get_available_devices(token) do
    case Client.get("/me/player/devices", [], token) do
      {:ok, devices_map} -> {:ok, Devices.from_map(devices_map)}
      error -> error
    end
  end

  @doc """
  Get information about the user's currently playing track.
  Requires: user-read-currently-playing scope.
  """
  @spec get_currently_playing(String.t()) :: {:ok, PlaybackState.t() | nil} | {:error, any()}
  def get_currently_playing(token) do
    case Client.get("/me/player/currently-playing", [], token) do
      {:ok, nil} -> {:ok, nil}  # Nothing currently playing
      {:ok, %{} = current_map} -> {:ok, PlaybackState.from_map(current_map)}
      error -> error
    end
  end

  @doc """
  Start or resume playback on the user's active device.
  **Warning:** This will start or change playback for the user.
  Requires: user-modify-playback-state scope.
  """
  @spec start_playback(String.t(), map) :: {:ok, any()} | {:error, any()}
  def start_playback(token, body \\ %{}) do
    Client.put("/me/player/play", body, [], token)
  end

  @doc """
  Pause playback on the user's active device.
  **Warning:** This will pause playback for the user.
  Requires: user-modify-playback-state scope.
  """
  @spec pause_playback(String.t()) :: {:ok, any()} | {:error, any()}
  def pause_playback(token) do
    Client.put("/me/player/pause", %{}, [], token)
  end

  @doc """
  Skip to the next track in the user's queue.
  **Warning:** This will change playback for the user.
  Requires: user-modify-playback-state scope.
  """
  @spec skip_to_next(String.t()) :: {:ok, any()} | {:error, any()}
  def skip_to_next(token) do
    Client.post("/me/player/next", %{}, [], token)
  end

  @doc """
  Skip to the previous track in the user's queue.
  **Warning:** This will change playback for the user.
  Requires: user-modify-playback-state scope.
  """
  @spec skip_to_previous(String.t()) :: {:ok, any()} | {:error, any()}
  def skip_to_previous(token) do
    Client.post("/me/player/previous", %{}, [], token)
  end

  @doc """
  Seek to a position in the currently playing track.
  **Warning:** This will change playback for the user.
  Requires: user-modify-playback-state scope.
  """
  @spec seek_to_position(String.t(), integer) :: {:ok, any()} | {:error, any()}
  def seek_to_position(token, position_ms) do
    Client.put("/me/player/seek?position_ms=#{position_ms}", %{}, [], token)
  end

  @doc """
  Set repeat mode for playback.
  **Warning:** This will change playback for the user.
  Requires: user-modify-playback-state scope.
  """
  @spec set_repeat_mode(String.t(), String.t()) :: {:ok, any()} | {:error, any()}
  def set_repeat_mode(token, state) do
    Client.put("/me/player/repeat?state=#{state}", %{}, [], token)
  end

  @doc """
  Set playback volume.
  **Warning:** This will change playback for the user.
  Requires: user-modify-playback-state scope.
  """
  @spec set_playback_volume(String.t(), integer) :: {:ok, any()} | {:error, any()}
  def set_playback_volume(token, volume_percent) do
    Client.put("/me/player/volume?volume_percent=#{volume_percent}", %{}, [], token)
  end

  @doc """
  Toggle shuffle playback.
  **Warning:** This will change playback for the user.
  Requires: user-modify-playback-state scope.
  """
  @spec toggle_shuffle(String.t(), boolean) :: {:ok, any()} | {:error, any()}
  def toggle_shuffle(token, state) do
    Client.put("/me/player/shuffle?state=#{state}", %{}, [], token)
  end

  @doc """
  Get the user's recently played tracks (paginated).
  Requires: user-read-recently-played scope.
  """
  @spec get_recently_played(String.t(), keyword) :: {:ok, RecentlyPlayed.t()} | {:error, any()}
  def get_recently_played(token, opts \\ []) do
    query = URI.encode_query(opts)
    path = "/me/player/recently-played" <> if(query != "", do: "?#{query}", else: "")
    case Client.get(path, [], token) do
      {:ok, recently_played_map} -> {:ok, RecentlyPlayed.from_map(recently_played_map)}
      error -> error
    end
  end

  @doc """
  Get the user's current playback queue.
  Requires: user-read-playback-state scope.
  """
  @spec get_queue(String.t()) :: {:ok, Queue.t()} | {:error, any()}
  def get_queue(token) do
    case Client.get("/me/player/queue", [], token) do
      {:ok, queue_map} -> {:ok, Queue.from_map(queue_map)}
      error -> error
    end
  end

  @doc """
  Add an item to the end of the user's playback queue.
  **Warning:** This will change playback for the user.
  Requires: user-modify-playback-state scope.
  """
  @spec add_to_queue(String.t(), String.t()) :: {:ok, any()} | {:error, any()}
  def add_to_queue(token, uri) do
    Client.post("/me/player/queue?uri=#{uri}", %{}, [], token)
  end
end
