defmodule Exspotify.Player do
  @moduledoc """
  Provides functions for interacting with the Player endpoints of the Spotify Web API.
  **Most endpoints require a user access token with appropriate scopes and an active device.**
  See: https://developer.spotify.com/documentation/web-api/reference/player
  """

  alias Exspotify.Client

  @doc """
  Get information about the user's current playback state.
  Requires: user-read-playback-state scope.
  """
  @spec get_playback_state(String.t()) :: any
  def get_playback_state(token) do
    Client.get("/me/player", [], token)
  end

  @doc """
  Transfer playback to a new device.
  **Warning:** This will change the user's active playback device.
  Requires: user-modify-playback-state scope.
  """
  @spec transfer_playback(String.t(), [String.t()]) :: any
  def transfer_playback(token, device_ids) when is_list(device_ids) do
    body = %{device_ids: device_ids}
    Client.put("/me/player", body, [], token)
  end

  @doc """
  Get a list of the user's available devices.
  Requires: user-read-playback-state scope.
  """
  @spec get_available_devices(String.t()) :: any
  def get_available_devices(token) do
    Client.get("/me/player/devices", [], token)
  end

  @doc """
  Get information about the user's currently playing track.
  Requires: user-read-currently-playing scope.
  """
  @spec get_currently_playing(String.t()) :: any
  def get_currently_playing(token) do
    Client.get("/me/player/currently-playing", [], token)
  end

  @doc """
  Start or resume playback on the user's active device.
  **Warning:** This will start or change playback for the user.
  Requires: user-modify-playback-state scope.
  """
  @spec start_playback(String.t(), map) :: any
  def start_playback(token, body \\ %{}) do
    Client.put("/me/player/play", body, [], token)
  end

  @doc """
  Pause playback on the user's active device.
  **Warning:** This will pause playback for the user.
  Requires: user-modify-playback-state scope.
  """
  @spec pause_playback(String.t()) :: any
  def pause_playback(token) do
    Client.put("/me/player/pause", %{}, [], token)
  end

  @doc """
  Skip to the next track in the user's queue.
  **Warning:** This will change playback for the user.
  Requires: user-modify-playback-state scope.
  """
  @spec skip_to_next(String.t()) :: any
  def skip_to_next(token) do
    Client.post("/me/player/next", %{}, [], token)
  end

  @doc """
  Skip to the previous track in the user's queue.
  **Warning:** This will change playback for the user.
  Requires: user-modify-playback-state scope.
  """
  @spec skip_to_previous(String.t()) :: any
  def skip_to_previous(token) do
    Client.post("/me/player/previous", %{}, [], token)
  end

  @doc """
  Seek to a position in the currently playing track.
  **Warning:** This will change playback for the user.
  Requires: user-modify-playback-state scope.
  """
  @spec seek_to_position(String.t(), integer) :: any
  def seek_to_position(token, position_ms) do
    Client.put("/me/player/seek?position_ms=#{position_ms}", %{}, [], token)
  end

  @doc """
  Set repeat mode for playback.
  **Warning:** This will change playback for the user.
  Requires: user-modify-playback-state scope.
  """
  @spec set_repeat_mode(String.t(), String.t()) :: any
  def set_repeat_mode(token, state) do
    Client.put("/me/player/repeat?state=#{state}", %{}, [], token)
  end

  @doc """
  Set playback volume.
  **Warning:** This will change playback for the user.
  Requires: user-modify-playback-state scope.
  """
  @spec set_playback_volume(String.t(), integer) :: any
  def set_playback_volume(token, volume_percent) do
    Client.put("/me/player/volume?volume_percent=#{volume_percent}", %{}, [], token)
  end

  @doc """
  Toggle shuffle playback.
  **Warning:** This will change playback for the user.
  Requires: user-modify-playback-state scope.
  """
  @spec toggle_shuffle(String.t(), boolean) :: any
  def toggle_shuffle(token, state) do
    Client.put("/me/player/shuffle?state=#{state}", %{}, [], token)
  end

  @doc """
  Get the user's recently played tracks (paginated).
  Requires: user-read-recently-played scope.
  """
  @spec get_recently_played(String.t(), keyword) :: any
  def get_recently_played(token, opts \\ []) do
    query = URI.encode_query(opts)
    path = "/me/player/recently-played" <> if(query != "", do: "?#{query}", else: "")
    Client.get(path, [], token)
  end

  @doc """
  Get the user's current playback queue.
  Requires: user-read-playback-state scope.
  """
  @spec get_queue(String.t()) :: any
  def get_queue(token) do
    Client.get("/me/player/queue", [], token)
  end

  @doc """
  Add an item to the end of the user's playback queue.
  **Warning:** This will change playback for the user.
  Requires: user-modify-playback-state scope.
  """
  @spec add_to_queue(String.t(), String.t()) :: any
  def add_to_queue(token, uri) do
    Client.post("/me/player/queue?uri=#{uri}", %{}, [], token)
  end
end
