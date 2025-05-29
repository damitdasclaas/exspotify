defmodule Exspotify.Episodes do
  @moduledoc """
  Provides functions for interacting with the Episodes endpoints of the Spotify Web API.
  See: https://developer.spotify.com/documentation/web-api/reference/episodes
  """

  alias Exspotify.Client
  alias Exspotify.Structs.{Episode, Paging}

  @doc """
  Get Spotify catalog information for a single episode by its unique Spotify ID.
  https://developer.spotify.com/documentation/web-api/reference/get-episode
  """
  @spec get_episode(String.t(), String.t()) :: {:ok, Episode.t()} | {:error, any()}
  def get_episode(episode_id, token) do
    case Client.get("/episodes/#{episode_id}", [], token) do
      {:ok, episode_map} -> {:ok, Episode.from_map(episode_map)}
      error -> error
    end
  end

  @doc """
  Get Spotify catalog information for several episodes based on their Spotify IDs.
  https://developer.spotify.com/documentation/web-api/reference/get-several-episodes
  """
  @spec get_several_episodes([String.t()], String.t()) :: {:ok, [Episode.t()]} | {:error, any()}
  def get_several_episodes(episode_ids, token) when is_list(episode_ids) do
    ids_param = Enum.join(episode_ids, ",")
    case Client.get("/episodes?ids=#{ids_param}", [], token) do
      {:ok, %{"episodes" => episodes_list}} ->
        episodes = Enum.map(episodes_list, &Episode.from_map/1)
        {:ok, episodes}
      error -> error
    end
  end

  @doc """
  Get a list of the episodes saved in the current Spotify user's library (paginated).
  Returns a Paging struct containing saved episodes with added_at timestamps.
  https://developer.spotify.com/documentation/web-api/reference/get-users-saved-episodes
  """
  @spec get_users_saved_episodes(String.t(), keyword) :: {:ok, Paging.t()} | {:error, any()}
  def get_users_saved_episodes(token, opts \\ []) do
    query = URI.encode_query(opts)
    path = "/me/episodes" <> if(query != "", do: "?#{query}", else: "")
    case Client.get(path, [], token) do
      {:ok, paging_map} ->
        # Parse items as maps with added_at and episode fields
        parsed_paging = Paging.from_map(paging_map, fn item ->
          %{
            "added_at" => item["added_at"],
            "episode" => Episode.from_map(item["episode"])
          }
        end)
        {:ok, parsed_paging}
      error -> error
    end
  end

  @doc """
  Save one or more episodes to the current user's library.
  https://developer.spotify.com/documentation/web-api/reference/save-episodes-user
  """
  @spec save_episodes_for_current_user([String.t()], String.t()) :: {:ok, any()} | {:error, any()}
  def save_episodes_for_current_user(episode_ids, token) when is_list(episode_ids) do
    query = URI.encode_query(%{"ids" => Enum.join(episode_ids, ",")})
    Client.put("/me/episodes?#{query}", %{}, [], token)
  end

  @doc """
  Remove one or more episodes from the current user's library.
  https://developer.spotify.com/documentation/web-api/reference/remove-episodes-user
  """
  @spec remove_users_saved_episodes([String.t()], String.t()) :: {:ok, any()} | {:error, any()}
  def remove_users_saved_episodes(episode_ids, token) when is_list(episode_ids) do
    query = URI.encode_query(%{"ids" => Enum.join(episode_ids, ",")})
    Client.delete("/me/episodes?#{query}", [], token)
  end

  @doc """
  Check if one or more episodes are saved in the current user's library.
  Returns a list of booleans corresponding to the episode IDs.
  https://developer.spotify.com/documentation/web-api/reference/check-users-saved-episodes
  """
  @spec check_users_saved_episodes([String.t()], String.t()) :: {:ok, [boolean()]} | {:error, any()}
  def check_users_saved_episodes(episode_ids, token) when is_list(episode_ids) do
    query = URI.encode_query(%{"ids" => Enum.join(episode_ids, ",")})
    Client.get("/me/episodes/contains?#{query}", [], token)
  end
end
