defmodule Exspotify.Shows do
  @moduledoc """
  Provides functions for interacting with the Shows endpoints of the Spotify Web API.
  See: https://developer.spotify.com/documentation/web-api/reference/shows

  Note: The Shows API may not be fully supported by Spotify, may return 'resource not found', and does not have a dedicated scope. Use with caution.
  """

  alias Exspotify.Client
  alias Exspotify.Structs.{Show, Episode, Paging}

  @doc """
  Get Spotify catalog information for a single show by its unique Spotify ID.
  https://developer.spotify.com/documentation/web-api/reference/get-show
  """
  @spec get_show(String.t(), String.t()) :: {:ok, Show.t()} | {:error, any()}
  def get_show(show_id, token) do
    case Client.get("/shows/#{show_id}", [], token) do
      {:ok, show_map} -> {:ok, Show.from_map(show_map)}
      error -> error
    end
  end

  @doc """
  Get Spotify catalog information for several shows based on their Spotify IDs.
  https://developer.spotify.com/documentation/web-api/reference/get-several-shows
  """
  @spec get_several_shows([String.t()], String.t()) :: {:ok, [Show.t()]} | {:error, any()}
  def get_several_shows(show_ids, token) when is_list(show_ids) do
    ids_param = Enum.join(show_ids, ",")
    case Client.get("/shows?ids=#{ids_param}", [], token) do
      {:ok, %{"shows" => shows_list}} ->
        shows = Enum.map(shows_list, &Show.from_map/1)
        {:ok, shows}
      error -> error
    end
  end

  @doc """
  Get Spotify catalog information about a show's episodes (paginated).
  https://developer.spotify.com/documentation/web-api/reference/get-shows-episodes
  """
  @spec get_show_episodes(String.t(), String.t(), keyword) :: {:ok, Paging.t()} | {:error, any()}
  def get_show_episodes(show_id, token, opts \\ []) do
    query = URI.encode_query(opts)
    path = "/shows/#{show_id}/episodes" <> if(query != "", do: "?#{query}", else: "")
    case Client.get(path, [], token) do
      {:ok, paging_map} ->
        parsed_paging = Paging.from_map(paging_map, &Episode.from_map/1)
        {:ok, parsed_paging}
      error -> error
    end
  end

  @doc """
  Get a list of the shows saved in the current Spotify user's library (paginated).
  Returns a Paging struct containing saved shows with added_at timestamps.
  https://developer.spotify.com/documentation/web-api/reference/get-users-saved-shows
  """
  @spec get_users_saved_shows(String.t(), keyword) :: {:ok, Paging.t()} | {:error, any()}
  def get_users_saved_shows(token, opts \\ []) do
    query = URI.encode_query(opts)
    path = "/me/shows" <> if(query != "", do: "?#{query}", else: "")
    case Client.get(path, [], token) do
      {:ok, paging_map} ->
        # Parse items as maps with added_at and show fields
        parsed_paging = Paging.from_map(paging_map, fn item ->
          %{
            "added_at" => item["added_at"],
            "show" => Show.from_map(item["show"])
          }
        end)
        {:ok, parsed_paging}
      error -> error
    end
  end

  @doc """
  Save one or more shows to the current user's library.
  https://developer.spotify.com/documentation/web-api/reference/save-shows-user
  """
  @spec save_shows_for_current_user([String.t()], String.t()) :: {:ok, any()} | {:error, any()}
  def save_shows_for_current_user(show_ids, token) when is_list(show_ids) do
    query = URI.encode_query(%{"ids" => Enum.join(show_ids, ",")})
    Client.put("/me/shows?#{query}", %{}, [], token)
  end

  @doc """
  Remove one or more shows from the current user's library.
  https://developer.spotify.com/documentation/web-api/reference/remove-shows-user
  """
  @spec remove_users_saved_shows([String.t()], String.t()) :: {:ok, any()} | {:error, any()}
  def remove_users_saved_shows(show_ids, token) when is_list(show_ids) do
    query = URI.encode_query(%{"ids" => Enum.join(show_ids, ",")})
    Client.delete("/me/shows?#{query}", [], token)
  end

  @doc """
  Check if one or more shows are saved in the current user's library.
  Returns a list of booleans corresponding to the show IDs.
  https://developer.spotify.com/documentation/web-api/reference/check-users-saved-shows
  """
  @spec check_users_saved_shows([String.t()], String.t()) :: {:ok, [boolean()]} | {:error, any()}
  def check_users_saved_shows(show_ids, token) when is_list(show_ids) do
    query = URI.encode_query(%{"ids" => Enum.join(show_ids, ",")})
    Client.get("/me/shows/contains?#{query}", [], token)
  end
end
