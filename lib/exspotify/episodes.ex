defmodule Exspotify.Episodes do
  @moduledoc """
  Provides functions for interacting with the Episodes endpoints of the Spotify Web API.
  See: https://developer.spotify.com/documentation/web-api/reference/episodes
  """

  alias Exspotify.Client
  alias Exspotify.Pagination

  @doc """
  Get Spotify catalog information for a single episode by its unique Spotify ID.
  https://developer.spotify.com/documentation/web-api/reference/get-episode
  """
  @spec get_episode(String.t(), String.t()) :: any
  def get_episode(episode_id, token) do
    Client.get("/episodes/#{episode_id}", [], token)
  end

  @doc """
  Get Spotify catalog information for several episodes based on their Spotify IDs.
  https://developer.spotify.com/documentation/web-api/reference/get-several-episodes
  """
  @spec get_several_episodes([String.t()], String.t()) :: any
  def get_several_episodes(episode_ids, token) when is_list(episode_ids) do
    ids_param = Enum.join(episode_ids, ",")
    Client.get("/episodes?ids=#{ids_param}", [], token)
  end

  @doc """
  Get a list of the episodes saved in the current Spotify user's library (paginated).
  https://developer.spotify.com/documentation/web-api/reference/get-users-saved-episodes
  """
  @spec get_users_saved_episodes(String.t(), keyword) :: any
  def get_users_saved_episodes(token, opts \\ []) do
    query = URI.encode_query(opts)
    path = "/me/episodes" <> if(query != "", do: "?#{query}", else: "")
    Client.get(path, [], token)
  end

  @doc """
  Fetches all saved episodes for the user, following all pages.

  **Warning:** This may make a large number of requests if the user has many saved episodes.
  You can limit the number of items fetched with the `:max_items` option (default: 200).
  """
  @spec get_all_users_saved_episodes(String.t(), keyword) :: [map]
  def get_all_users_saved_episodes(token, opts \\ []) do
    max_items = Keyword.get(opts, :max_items, 200)
    fetch_page = fn page_opts -> get_users_saved_episodes(token, page_opts) end
    Pagination.fetch_all(fetch_page, opts, max_items)
  end

  @doc """
  Save one or more episodes to the current user's library.
  https://developer.spotify.com/documentation/web-api/reference/save-episodes-user
  """
  @spec save_episodes_for_current_user([String.t()], String.t()) :: any
  def save_episodes_for_current_user(episode_ids, token) when is_list(episode_ids) do
    query = URI.encode_query(%{"ids" => Enum.join(episode_ids, ",")})
    Client.put("/me/episodes?#{query}", %{}, [], token)
  end

  @doc """
  Remove one or more episodes from the current user's library.
  https://developer.spotify.com/documentation/web-api/reference/remove-episodes-user
  """
  @spec remove_users_saved_episodes([String.t()], String.t()) :: any
  def remove_users_saved_episodes(episode_ids, token) when is_list(episode_ids) do
    query = URI.encode_query(%{"ids" => Enum.join(episode_ids, ",")})
    Client.delete("/me/episodes?#{query}", [], token)
  end

  @doc """
  Check if one or more episodes are saved in the current user's library.
  https://developer.spotify.com/documentation/web-api/reference/check-users-saved-episodes
  """
  @spec check_users_saved_episodes([String.t()], String.t()) :: any
  def check_users_saved_episodes(episode_ids, token) when is_list(episode_ids) do
    query = URI.encode_query(%{"ids" => Enum.join(episode_ids, ",")})
    Client.get("/me/episodes/contains?#{query}", [], token)
  end
end
