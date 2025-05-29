defmodule Exspotify.Users do
  @moduledoc """
  Provides functions for interacting with the Users endpoints of the Spotify Web API.
  See: https://developer.spotify.com/documentation/web-api/reference/users-profile
  """

  alias Exspotify.Client

  @doc """
  Get the current user's profile.
  https://developer.spotify.com/documentation/web-api/reference/get-current-users-profile
  """
  @spec get_current_user_profile(String.t()) :: any
  def get_current_user_profile(token) do
    Client.get("/me", [], token)
  end

  @doc """
  Get a user's public profile by their Spotify user ID.
  https://developer.spotify.com/documentation/web-api/reference/get-users-profile
  """
  @spec get_user_profile(String.t(), String.t()) :: any
  def get_user_profile(user_id, token) do
    Client.get("/users/#{user_id}", [], token)
  end

  @doc """
  Get the current user's top artists or tracks (paginated).
  https://developer.spotify.com/documentation/web-api/reference/get-users-top-artists-and-tracks
  type: "artists" or "tracks"
  """
  @spec get_user_top_items(String.t(), String.t(), keyword) :: any
  def get_user_top_items(type, token, opts \\ []) do
    query = URI.encode_query(opts)
    path = "/me/top/#{type}" <> if(query != "", do: "?#{query}", else: "")
    Client.get(path, [], token)
  end

  @doc """
  Follow artists or users.
  **Warning:** This will change the user's followed artists or users.
  type: "artist" or "user"
  https://developer.spotify.com/documentation/web-api/reference/follow-artists-users
  """
  @spec follow_artists_or_users(String.t(), String.t(), [String.t()], String.t()) :: any
  def follow_artists_or_users(type, token, ids, _context_user_id \\ nil) when is_list(ids) do
    query = URI.encode_query(%{"type" => type, "ids" => Enum.join(ids, ",")})
    Client.put("/me/following?#{query}", %{}, [], token)
  end

  @doc """
  Unfollow artists or users.
  **Warning:** This will change the user's followed artists or users.
  type: "artist" or "user"
  https://developer.spotify.com/documentation/web-api/reference/unfollow-artists-users
  """
  @spec unfollow_artists_or_users(String.t(), String.t(), [String.t()], String.t()) :: any
  def unfollow_artists_or_users(type, token, ids, _context_user_id \\ nil) when is_list(ids) do
    query = URI.encode_query(%{"type" => type, "ids" => Enum.join(ids, ",")})
    Client.delete("/me/following?#{query}", [], token)
  end

  @doc """
  Check if the current user follows one or more artists or users.
  type: "artist" or "user"
  https://developer.spotify.com/documentation/web-api/reference/check-current-user-follows
  """
  @spec check_if_user_follows_artists_or_users(String.t(), String.t(), [String.t()], String.t()) :: any
  def check_if_user_follows_artists_or_users(type, token, ids, _context_user_id \\ nil) when is_list(ids) do
    query = URI.encode_query(%{"type" => type, "ids" => Enum.join(ids, ",")})
    Client.get("/me/following/contains?#{query}", [], token)
  end

  @doc """
  Get the current user's followed artists (paginated).
  https://developer.spotify.com/documentation/web-api/reference/get-followed-artists
  """
  @spec get_followed_artists(String.t(), keyword) :: any
  def get_followed_artists(token, opts \\ []) do
    query = URI.encode_query(opts)
    path = "/me/following?type=artist" <> if(query != "", do: "&#{query}", else: "")
    case Client.get(path, [], token) do
      {:ok, %{"artists" => artists}} -> {:ok, artists}
      other -> other
    end
  end
end
