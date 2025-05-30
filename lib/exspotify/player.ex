defmodule Exspotify.Player do
  @moduledoc """
  Provides functions for interacting with the Player endpoints of the Spotify Web API.
  **Most endpoints require a user access token with appropriate scopes and an active device.**
  See: https://developer.spotify.com/documentation/web-api/reference/player
  """

  alias Exspotify.{Client, Error}
  alias Exspotify.Structs.{PlaybackState, Devices, Queue, RecentlyPlayed}

  @doc """
  Get information about the user's current playback state.
  Requires: user-read-playback-state scope.
  """
  @spec get_playback_state(String.t()) :: {:ok, PlaybackState.t() | nil} | {:error, Error.t()}
  def get_playback_state(token) do
    with :ok <- Error.validate_token(token),
         {:ok, response} <- Client.get("/me/player", [], token) do
      case response do
        nil -> {:ok, nil}  # No active device
        %{} = playback_map -> {:ok, PlaybackState.from_map(playback_map)}
        _ -> {:error, Error.new(:unexpected_response, "Invalid playback state response", %{response: response})}
      end
    end
  end

  @doc """
  Transfer playback to a new device.
  **Warning:** This will change the user's active playback device.
  Requires: user-modify-playback-state scope.
  """
  @spec transfer_playback(String.t(), [String.t()]) :: {:ok, any()} | {:error, Error.t()}
  def transfer_playback(token, device_ids) when is_list(device_ids) do
    with :ok <- Error.validate_token(token),
         :ok <- Error.validate_list(device_ids, "device_ids"),
         :ok <- validate_all_ids(device_ids, "device_ids") do
      body = %{device_ids: device_ids}
      Client.put("/me/player", body, [], token)
    end
  end

  def transfer_playback(_token, device_ids) do
    {:error, Error.new(:invalid_type, "device_ids must be a list, got: #{inspect(device_ids)}", %{value: device_ids})}
  end

  @doc """
  Get a list of the user's available devices.
  Requires: user-read-playback-state scope.
  """
  @spec get_available_devices(String.t()) :: {:ok, Devices.t()} | {:error, Error.t()}
  def get_available_devices(token) do
    with :ok <- Error.validate_token(token),
         {:ok, devices_map} <- Client.get("/me/player/devices", [], token) do
      {:ok, Devices.from_map(devices_map)}
    end
  end

  @doc """
  Get information about the user's currently playing track.
  Requires: user-read-currently-playing scope.
  """
  @spec get_currently_playing(String.t()) :: {:ok, PlaybackState.t() | nil} | {:error, Error.t()}
  def get_currently_playing(token) do
    with :ok <- Error.validate_token(token),
         {:ok, response} <- Client.get("/me/player/currently-playing", [], token) do
      case response do
        nil -> {:ok, nil}  # Nothing currently playing
        %{} = current_map -> {:ok, PlaybackState.from_map(current_map)}
        _ -> {:error, Error.new(:unexpected_response, "Invalid currently playing response", %{response: response})}
      end
    end
  end

  @doc """
  Start or resume playback on the user's active device.
  **Warning:** This will start or change playback for the user.
  Requires: user-modify-playback-state scope.
  """
  @spec start_playback(String.t(), map) :: {:ok, any()} | {:error, Error.t()}
  def start_playback(token, body \\ %{}) do
    with :ok <- Error.validate_token(token) do
      Client.put("/me/player/play", body, [], token)
    end
  end

  @doc """
  Pause playback on the user's active device.
  **Warning:** This will pause playback for the user.
  Requires: user-modify-playback-state scope.
  """
  @spec pause_playback(String.t()) :: {:ok, any()} | {:error, Error.t()}
  def pause_playback(token) do
    with :ok <- Error.validate_token(token) do
      Client.put("/me/player/pause", %{}, [], token)
    end
  end

  @doc """
  Skip to the next track in the user's queue.
  **Warning:** This will change playback for the user.
  Requires: user-modify-playback-state scope.
  """
  @spec skip_to_next(String.t()) :: {:ok, any()} | {:error, Error.t()}
  def skip_to_next(token) do
    with :ok <- Error.validate_token(token) do
      Client.post("/me/player/next", %{}, [], token)
    end
  end

  @doc """
  Skip to the previous track in the user's queue.
  **Warning:** This will change playback for the user.
  Requires: user-modify-playback-state scope.
  """
  @spec skip_to_previous(String.t()) :: {:ok, any()} | {:error, Error.t()}
  def skip_to_previous(token) do
    with :ok <- Error.validate_token(token) do
      Client.post("/me/player/previous", %{}, [], token)
    end
  end

  @doc """
  Seek to a position in the currently playing track.
  **Warning:** This will change playback for the user.
  Requires: user-modify-playback-state scope.
  """
  @spec seek_to_position(String.t(), integer) :: {:ok, any()} | {:error, Error.t()}
  def seek_to_position(token, position_ms) do
    with :ok <- Error.validate_token(token),
         :ok <- validate_position(position_ms) do
      Client.put("/me/player/seek?position_ms=#{position_ms}", %{}, [], token)
    end
  end

  @doc """
  Set repeat mode for playback.
  **Warning:** This will change playback for the user.
  Requires: user-modify-playback-state scope.
  """
  @spec set_repeat_mode(String.t(), String.t()) :: {:ok, any()} | {:error, Error.t()}
  def set_repeat_mode(token, state) do
    with :ok <- Error.validate_token(token),
         :ok <- validate_repeat_state(state) do
      Client.put("/me/player/repeat?state=#{state}", %{}, [], token)
    end
  end

  @doc """
  Set playback volume.
  **Warning:** This will change playback for the user.
  Requires: user-modify-playback-state scope.
  """
  @spec set_playback_volume(String.t(), integer) :: {:ok, any()} | {:error, Error.t()}
  def set_playback_volume(token, volume_percent) do
    with :ok <- Error.validate_token(token),
         :ok <- validate_volume(volume_percent) do
      Client.put("/me/player/volume?volume_percent=#{volume_percent}", %{}, [], token)
    end
  end

  @doc """
  Toggle shuffle playback.
  **Warning:** This will change playback for the user.
  Requires: user-modify-playback-state scope.
  """
  @spec toggle_shuffle(String.t(), boolean) :: {:ok, any()} | {:error, Error.t()}
  def toggle_shuffle(token, state) do
    with :ok <- Error.validate_token(token),
         :ok <- validate_shuffle_state(state) do
      Client.put("/me/player/shuffle?state=#{state}", %{}, [], token)
    end
  end

  @doc """
  Get the user's recently played tracks (paginated).
  Requires: user-read-recently-played scope.
  """
  @spec get_recently_played(String.t(), keyword) :: {:ok, RecentlyPlayed.t()} | {:error, Error.t()}
  def get_recently_played(token, opts \\ []) do
    with :ok <- Error.validate_token(token) do
      query = URI.encode_query(opts)
      path = "/me/player/recently-played" <> if(query != "", do: "?#{query}", else: "")
      case Client.get(path, [], token) do
        {:ok, recently_played_map} -> {:ok, RecentlyPlayed.from_map(recently_played_map)}
        {:error, error} -> {:error, error}
      end
    end
  end

  @doc """
  Get the user's current playback queue.
  Requires: user-read-playback-state scope.
  """
  @spec get_queue(String.t()) :: {:ok, Queue.t()} | {:error, Error.t()}
  def get_queue(token) do
    with :ok <- Error.validate_token(token),
         {:ok, queue_map} <- Client.get("/me/player/queue", [], token) do
      {:ok, Queue.from_map(queue_map)}
    end
  end

  @doc """
  Add an item to the end of the user's playback queue.
  **Warning:** This will change playback for the user.
  Requires: user-modify-playback-state scope.
  """
  @spec add_to_queue(String.t(), String.t()) :: {:ok, any()} | {:error, Error.t()}
  def add_to_queue(token, uri) do
    with :ok <- Error.validate_token(token),
         :ok <- validate_uri(uri) do
      Client.post("/me/player/queue?uri=#{uri}", %{}, [], token)
    end
  end

  # Private helper to validate all IDs in a list
  defp validate_all_ids(ids, field_name) do
    case Enum.find_index(ids, &(!is_binary(&1) || byte_size(&1) == 0)) do
      nil -> :ok
      index ->
        invalid_id = Enum.at(ids, index)
        {:error, Error.new(:invalid_id, "#{field_name}[#{index}] must be a non-empty string, got: #{inspect(invalid_id)}", %{field: field_name, index: index, value: invalid_id})}
    end
  end

  # Private helper to validate position_ms
  defp validate_position(position_ms) when is_integer(position_ms) and position_ms >= 0, do: :ok
  defp validate_position(position_ms) do
    {:error, Error.new(:invalid_type, "position_ms must be a non-negative integer, got: #{inspect(position_ms)}", %{field: "position_ms", value: position_ms})}
  end

  # Private helper to validate repeat state
  defp validate_repeat_state(state) when state in ["off", "track", "context"], do: :ok
  defp validate_repeat_state(state) do
    {:error, Error.new(:invalid_type, "repeat state must be 'off', 'track', or 'context', got: #{inspect(state)}", %{field: "state", value: state, valid_values: ["off", "track", "context"]})}
  end

  # Private helper to validate volume
  defp validate_volume(volume) when is_integer(volume) and volume >= 0 and volume <= 100, do: :ok
  defp validate_volume(volume) do
    {:error, Error.new(:invalid_type, "volume_percent must be an integer between 0 and 100, got: #{inspect(volume)}", %{field: "volume_percent", value: volume, valid_range: "0-100"})}
  end

  # Private helper to validate shuffle state
  defp validate_shuffle_state(state) when is_boolean(state), do: :ok
  defp validate_shuffle_state(state) do
    {:error, Error.new(:invalid_type, "shuffle state must be a boolean, got: #{inspect(state)}", %{field: "state", value: state})}
  end

  # Private helper to validate URI
  defp validate_uri(uri) when is_binary(uri) and byte_size(uri) > 0, do: :ok
  defp validate_uri(uri) do
    {:error, Error.new(:invalid_id, "URI must be a non-empty string, got: #{inspect(uri)}", %{field: "uri", value: uri})}
  end
end
