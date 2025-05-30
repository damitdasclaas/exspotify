defmodule Exspotify.Playlists do
  @moduledoc """
  Provides functions for interacting with the Playlists endpoints of the Spotify Web API.
  Deprecated endpoints (featured playlists, category playlists) are not included.
  See: https://developer.spotify.com/documentation/web-api/reference/playlists
  """

  alias Exspotify.{Client, Error}
  alias Exspotify.Structs.{Playlist, Track, Episode, Paging}

  @doc """
  Get a playlist by its Spotify ID.
  Requires: playlist-read-private or playlist-read-collaborative scope for private playlists.
  """
  @spec get_playlist(String.t(), String.t()) :: {:ok, Playlist.t()} | {:error, Error.t()}
  def get_playlist(playlist_id, token) do
    with :ok <- Error.validate_id(playlist_id, "playlist_id"),
         :ok <- Error.validate_token(token),
         {:ok, playlist_map} <- Client.get("/playlists/#{playlist_id}", [], token) do
      {:ok, Playlist.from_map(playlist_map)}
    end
  end

  @doc """
  Change a playlist's details (name, description, public, collaborative).
  **Warning:** This will change the playlist's metadata.
  Requires: playlist-modify-public or playlist-modify-private scope.
  """
  @spec change_playlist_details(String.t(), String.t(), map) :: {:ok, any()} | {:error, Error.t()}
  def change_playlist_details(playlist_id, token, details) do
    with :ok <- Error.validate_id(playlist_id, "playlist_id"),
         :ok <- Error.validate_token(token) do
      Client.put("/playlists/#{playlist_id}", details, [], token)
    end
  end

  @doc """
  Get items (tracks/episodes) in a playlist (paginated).
  https://developer.spotify.com/documentation/web-api/reference/get-playlists-tracks
  """
  @spec get_playlist_items(String.t(), String.t(), keyword) :: {:ok, Paging.t()} | {:error, Error.t()}
  def get_playlist_items(playlist_id, token, opts \\ []) do
    with :ok <- Error.validate_id(playlist_id, "playlist_id"),
         :ok <- Error.validate_token(token) do
      query = URI.encode_query(opts)
      path = "/playlists/#{playlist_id}/tracks" <> if(query != "", do: "?#{query}", else: "")
      case Client.get(path, [], token) do
        {:ok, paging_map} ->
          # Parse playlist items which can be tracks or episodes wrapped in a playlist item object
          parsed_paging = Paging.from_map(paging_map, fn item ->
            %{
              "added_at" => item["added_at"],
              "added_by" => item["added_by"],
              "is_local" => item["is_local"],
              "track" => parse_playlist_track(item["track"])
            }
          end)
          {:ok, parsed_paging}
        {:error, error} -> {:error, error}
      end
    end
  end

  @doc """
  Get the current user's playlists (paginated).
  https://developer.spotify.com/documentation/web-api/reference/get-current-users-playlists
  """
  @spec get_current_users_playlists(String.t(), keyword) :: {:ok, Paging.t()} | {:error, Error.t()}
  def get_current_users_playlists(token, opts \\ []) do
    with :ok <- Error.validate_token(token) do
      query = URI.encode_query(opts)
      path = "/me/playlists" <> if(query != "", do: "?#{query}", else: "")
      case Client.get(path, [], token) do
        {:ok, paging_map} ->
          parsed_paging = Paging.from_map(paging_map, &Playlist.from_map/1)
          {:ok, parsed_paging}
        {:error, error} -> {:error, error}
      end
    end
  end

  @doc """
  Get a user's public playlists (paginated).
  https://developer.spotify.com/documentation/web-api/reference/get-list-users-playlists
  """
  @spec get_users_playlists(String.t(), String.t(), keyword) :: {:ok, Paging.t()} | {:error, Error.t()}
  def get_users_playlists(user_id, token, opts \\ []) do
    with :ok <- Error.validate_id(user_id, "user_id"),
         :ok <- Error.validate_token(token) do
      query = URI.encode_query(opts)
      path = "/users/#{user_id}/playlists" <> if(query != "", do: "?#{query}", else: "")
      case Client.get(path, [], token) do
        {:ok, paging_map} ->
          parsed_paging = Paging.from_map(paging_map, &Playlist.from_map/1)
          {:ok, parsed_paging}
        {:error, error} -> {:error, error}
      end
    end
  end

  @doc """
  Update (reorder/replace) items in a playlist.
  **Warning:** This will change the playlist's items.
  Requires: playlist-modify-public or playlist-modify-private scope.
  """
  @spec update_playlist_items(String.t(), String.t(), map, keyword) :: {:ok, any()} | {:error, Error.t()}
  def update_playlist_items(playlist_id, token, body, opts \\ []) do
    with :ok <- Error.validate_id(playlist_id, "playlist_id"),
         :ok <- Error.validate_token(token) do
      query = URI.encode_query(opts)
      path = "/playlists/#{playlist_id}/tracks" <> if(query != "", do: "?#{query}", else: "")
      Client.put(path, body, [], token)
    end
  end

  @doc """
  Add items (tracks/episodes) to a playlist.
  **Warning:** This will change the playlist's items.
  Requires: playlist-modify-public or playlist-modify-private scope.
  """
  @spec add_items_to_playlist(String.t(), String.t(), map) :: {:ok, any()} | {:error, Error.t()}
  def add_items_to_playlist(playlist_id, token, body) do
    with :ok <- Error.validate_id(playlist_id, "playlist_id"),
         :ok <- Error.validate_token(token) do
      Client.post("/playlists/#{playlist_id}/tracks", body, [], token)
    end
  end

  @doc """
  Remove items (tracks/episodes) from a playlist.
  **Warning:** This will change the playlist's items.
  Requires: playlist-modify-public or playlist-modify-private scope.
  """
  @spec remove_playlist_items(String.t(), String.t(), map) :: {:ok, any()} | {:error, Error.t()}
  def remove_playlist_items(playlist_id, token, body) do
    with :ok <- Error.validate_id(playlist_id, "playlist_id"),
         :ok <- Error.validate_token(token) do
      Client.delete("/playlists/#{playlist_id}/tracks", body, [], token)
    end
  end

  @doc """
  Create a playlist for a user.
  **Warning:** This will create a new playlist in the user's account.
  Requires: playlist-modify-public or playlist-modify-private scope.
  """
  @spec create_playlist(String.t(), String.t(), String.t(), map) :: {:ok, Playlist.t()} | {:error, Error.t()}
  def create_playlist(user_id, name, token, details \\ %{}) do
    with :ok <- Error.validate_id(user_id, "user_id"),
         :ok <- validate_playlist_name(name),
         :ok <- Error.validate_token(token) do
      body = Map.put(details, "name", name)
      case Client.post("/users/#{user_id}/playlists", body, [], token) do
        {:ok, playlist_map} -> {:ok, Playlist.from_map(playlist_map)}
        {:error, error} -> {:error, error}
      end
    end
  end

  @doc """
  Get the current image for a playlist.
  """
  @spec get_playlist_cover_image(String.t(), String.t()) :: {:ok, any()} | {:error, Error.t()}
  def get_playlist_cover_image(playlist_id, token) do
    with :ok <- Error.validate_id(playlist_id, "playlist_id"),
         :ok <- Error.validate_token(token) do
      Client.get("/playlists/#{playlist_id}/images", [], token)
    end
  end

  @doc """
  Add a custom cover image to a playlist.
  **Warning:** This will change the playlist's cover image.
  Requires: playlist-modify-public or playlist-modify-private scope.
  The image must be a Base64-encoded JPEG.
  """
  @spec add_custom_playlist_cover_image(String.t(), String.t(), String.t()) :: {:ok, any()} | {:error, Error.t()}
  def add_custom_playlist_cover_image(playlist_id, image_data, token) do
    with :ok <- Error.validate_id(playlist_id, "playlist_id"),
         :ok <- validate_image_data(image_data),
         :ok <- Error.validate_token(token) do
      headers = [{"Content-Type", "image/jpeg"}]
      Client.put("/playlists/#{playlist_id}/images", image_data, headers, token)
    end
  end

  @doc """
  Follow a playlist.
  **Warning:** This will add the playlist to the user's library.
  Requires: playlist-modify-public or playlist-modify-private scope.
  """
  @spec follow_playlist(String.t(), String.t(), map) :: {:ok, any()} | {:error, Error.t()}
  def follow_playlist(playlist_id, token, opts \\ %{}) do
    with :ok <- Error.validate_id(playlist_id, "playlist_id"),
         :ok <- Error.validate_token(token) do
      Client.put("/playlists/#{playlist_id}/followers", opts, [], token)
    end
  end

  @doc """
  Unfollow a playlist.
  **Warning:** This will remove the playlist from the user's library.
  Requires: playlist-modify-public or playlist-modify-private scope.
  """
  @spec unfollow_playlist(String.t(), String.t()) :: {:ok, any()} | {:error, Error.t()}
  def unfollow_playlist(playlist_id, token) do
    with :ok <- Error.validate_id(playlist_id, "playlist_id"),
         :ok <- Error.validate_token(token) do
      Client.delete("/playlists/#{playlist_id}/followers", %{}, [], token)
    end
  end

  @doc """
  Check if one or more users are following a playlist.
  """
  @spec check_if_user_follows_playlist(String.t(), String.t(), [String.t()]) :: {:ok, any()} | {:error, Error.t()}
  def check_if_user_follows_playlist(playlist_id, token, user_ids) when is_list(user_ids) do
    with :ok <- Error.validate_id(playlist_id, "playlist_id"),
         :ok <- Error.validate_token(token),
         :ok <- Error.validate_list(user_ids, "user_ids"),
         :ok <- validate_all_ids(user_ids, "user_ids") do
      query = URI.encode_query(%{"ids" => Enum.join(user_ids, ",")})
      Client.get("/playlists/#{playlist_id}/followers/contains?#{query}", [], token)
    end
  end

  def check_if_user_follows_playlist(_playlist_id, _token, user_ids) do
    {:error, Error.new(:invalid_type, "user_ids must be a list, got: #{inspect(user_ids)}", %{value: user_ids})}
  end

  # Private helper function to parse playlist track items (can be tracks or episodes)
  defp parse_playlist_track(nil), do: nil
  defp parse_playlist_track(%{"type" => "track"} = track_map), do: Track.from_map(track_map)
  defp parse_playlist_track(%{"type" => "episode"} = episode_map), do: Episode.from_map(episode_map)
  defp parse_playlist_track(other), do: other  # fallback for unknown types

  # Private helper to validate all IDs in a list
  defp validate_all_ids(ids, field_name) do
    case Enum.find_index(ids, &(!is_binary(&1) || byte_size(&1) == 0)) do
      nil -> :ok
      index ->
        invalid_id = Enum.at(ids, index)
        {:error, Error.new(:invalid_id, "#{field_name}[#{index}] must be a non-empty string, got: #{inspect(invalid_id)}", %{field: field_name, index: index, value: invalid_id})}
    end
  end

  # Private helper to validate playlist name
  defp validate_playlist_name(name) when is_binary(name) and byte_size(name) > 0, do: :ok
  defp validate_playlist_name(name) do
    {:error, Error.new(:invalid_id, "Playlist name must be a non-empty string, got: #{inspect(name)}", %{field: "name", value: name})}
  end

  # Private helper to validate image data
  defp validate_image_data(data) when is_binary(data) and byte_size(data) > 0, do: :ok
  defp validate_image_data(data) do
    {:error, Error.new(:invalid_id, "Image data must be a non-empty string, got: #{inspect(data)}", %{field: "image_data", value: data})}
  end
end
