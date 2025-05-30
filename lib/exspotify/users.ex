defmodule Exspotify.Users do
  @moduledoc """
  Provides functions for interacting with the Users endpoints of the Spotify Web API.
  See: https://developer.spotify.com/documentation/web-api/reference/users-profile
  """

  alias Exspotify.{Client, Error}
  alias Exspotify.Structs.{User, Artist, Track, Paging}

  @doc """
  Get the current user's profile.
  https://developer.spotify.com/documentation/web-api/reference/get-current-users-profile
  """
  @spec get_current_user_profile(String.t()) :: {:ok, User.t()} | {:error, Error.t()}
  def get_current_user_profile(token) do
    with :ok <- Error.validate_token(token),
         {:ok, user_map} <- Client.get("/me", [], token) do
      {:ok, User.from_map(user_map)}
    end
  end

  @doc """
  Get a user's public profile by their Spotify user ID.
  https://developer.spotify.com/documentation/web-api/reference/get-users-profile
  """
  @spec get_user_profile(String.t(), String.t()) :: {:ok, User.t()} | {:error, Error.t()}
  def get_user_profile(user_id, token) do
    with :ok <- Error.validate_id(user_id, "user_id"),
         :ok <- Error.validate_token(token),
         {:ok, user_map} <- Client.get("/users/#{user_id}", [], token) do
      {:ok, User.from_map(user_map)}
    end
  end

  @doc """
  Get the current user's top artists or tracks (paginated).
  https://developer.spotify.com/documentation/web-api/reference/get-users-top-artists-and-tracks
  type: "artists" or "tracks"
  """
  @spec get_user_top_items(String.t(), String.t(), keyword) :: {:ok, Paging.t()} | {:error, Error.t()}
  def get_user_top_items(type, token, opts \\ []) do
    with :ok <- validate_top_items_type(type),
         :ok <- Error.validate_token(token) do
      query = URI.encode_query(opts)
      path = "/me/top/#{type}" <> if(query != "", do: "?#{query}", else: "")
      case Client.get(path, [], token) do
        {:ok, paging_map} ->
          item_parser = case type do
            "artists" -> &Artist.from_map/1
            "tracks" -> &Track.from_map/1
            _ -> & &1  # fallback for unknown types
          end
          parsed_paging = Paging.from_map(paging_map, item_parser)
          {:ok, parsed_paging}
        {:error, error} -> {:error, error}
      end
    end
  end

  @doc """
  Follow artists or users.
  **Warning:** This will change the user's followed artists or users.
  type: "artist" or "user"
  https://developer.spotify.com/documentation/web-api/reference/follow-artists-users
  """
  @spec follow_artists_or_users(String.t(), String.t(), [String.t()], String.t()) :: {:ok, any()} | {:error, Error.t()}
  def follow_artists_or_users(type, token, ids, _context_user_id \\ nil) when is_list(ids) do
    with :ok <- validate_follow_type(type),
         :ok <- Error.validate_token(token),
         :ok <- Error.validate_list(ids, "ids"),
         :ok <- validate_all_ids(ids, "ids") do
      query = URI.encode_query(%{"type" => type, "ids" => Enum.join(ids, ",")})
      Client.put("/me/following?#{query}", %{}, [], token)
    end
  end

  def follow_artists_or_users(_type, _token, ids, _context_user_id) do
    {:error, Error.new(:invalid_type, "ids must be a list, got: #{inspect(ids)}", %{value: ids})}
  end

  @doc """
  Unfollow artists or users.
  **Warning:** This will change the user's followed artists or users.
  type: "artist" or "user"
  https://developer.spotify.com/documentation/web-api/reference/unfollow-artists-users
  """
  @spec unfollow_artists_or_users(String.t(), String.t(), [String.t()], String.t()) :: {:ok, any()} | {:error, Error.t()}
  def unfollow_artists_or_users(type, token, ids, _context_user_id \\ nil) when is_list(ids) do
    with :ok <- validate_follow_type(type),
         :ok <- Error.validate_token(token),
         :ok <- Error.validate_list(ids, "ids"),
         :ok <- validate_all_ids(ids, "ids") do
      query = URI.encode_query(%{"type" => type, "ids" => Enum.join(ids, ",")})
      Client.delete("/me/following?#{query}", [], token)
    end
  end

  def unfollow_artists_or_users(_type, _token, ids, _context_user_id) do
    {:error, Error.new(:invalid_type, "ids must be a list, got: #{inspect(ids)}", %{value: ids})}
  end

  @doc """
  Check if the current user follows one or more artists or users.
  type: "artist" or "user"
  https://developer.spotify.com/documentation/web-api/reference/check-current-user-follows
  """
  @spec check_if_user_follows_artists_or_users(String.t(), String.t(), [String.t()], String.t()) :: {:ok, [boolean()]} | {:error, Error.t()}
  def check_if_user_follows_artists_or_users(type, token, ids, _context_user_id \\ nil) when is_list(ids) do
    with :ok <- validate_follow_type(type),
         :ok <- Error.validate_token(token),
         :ok <- Error.validate_list(ids, "ids"),
         :ok <- validate_all_ids(ids, "ids") do
      query = URI.encode_query(%{"type" => type, "ids" => Enum.join(ids, ",")})
      Client.get("/me/following/contains?#{query}", [], token)
    end
  end

  def check_if_user_follows_artists_or_users(_type, _token, ids, _context_user_id) do
    {:error, Error.new(:invalid_type, "ids must be a list, got: #{inspect(ids)}", %{value: ids})}
  end

  @doc """
  Get the current user's followed artists (paginated).
  https://developer.spotify.com/documentation/web-api/reference/get-followed-artists
  """
  @spec get_followed_artists(String.t(), keyword) :: {:ok, Paging.t()} | {:error, Error.t()}
  def get_followed_artists(token, opts \\ []) do
    with :ok <- Error.validate_token(token) do
      query = URI.encode_query(opts)
      path = "/me/following?type=artist" <> if(query != "", do: "&#{query}", else: "")
      case Client.get(path, [], token) do
        {:ok, %{"artists" => paging_map}} ->
          parsed_paging = Paging.from_map(paging_map, &Artist.from_map/1)
          {:ok, parsed_paging}
        {:ok, response} ->
          {:error, Error.new(:unexpected_response, "Expected artists key in response", %{response: response})}
        {:error, error} -> {:error, error}
      end
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

  # Private helper to validate top items type
  defp validate_top_items_type(type) when type in ["artists", "tracks"], do: :ok
  defp validate_top_items_type(type) do
    {:error, Error.new(:invalid_type, "type must be 'artists' or 'tracks', got: #{inspect(type)}", %{value: type, valid_types: ["artists", "tracks"]})}
  end

  # Private helper to validate follow type
  defp validate_follow_type(type) when type in ["artist", "user"], do: :ok
  defp validate_follow_type(type) do
    {:error, Error.new(:invalid_type, "type must be 'artist' or 'user', got: #{inspect(type)}", %{value: type, valid_types: ["artist", "user"]})}
  end
end
