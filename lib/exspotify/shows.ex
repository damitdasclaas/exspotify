defmodule Exspotify.Shows do
  @moduledoc """
  Provides functions for interacting with the Shows endpoints of the Spotify Web API.
  See: https://developer.spotify.com/documentation/web-api/reference/shows

  Note: The Shows API may not be fully supported by Spotify, may return 'resource not found', and does not have a dedicated scope. Use with caution.
  """

  alias Exspotify.{Client, Error}
  alias Exspotify.Structs.{Show, Episode, Paging}

  @doc """
  Get Spotify catalog information for a single show by its unique Spotify ID.
  https://developer.spotify.com/documentation/web-api/reference/get-show
  """
  @spec get_show(String.t(), String.t()) :: {:ok, Show.t()} | {:error, Error.t()}
  def get_show(show_id, token) do
    with :ok <- Error.validate_id(show_id, "show_id"),
         :ok <- Error.validate_token(token),
         {:ok, show_map} <- Client.get("/shows/#{show_id}", [], token) do
      {:ok, Show.from_map(show_map)}
    end
  end

  @doc """
  Get Spotify catalog information for several shows based on their Spotify IDs.
  https://developer.spotify.com/documentation/web-api/reference/get-several-shows
  """
  @spec get_several_shows([String.t()], String.t()) :: {:ok, [Show.t()]} | {:error, Error.t()}
  def get_several_shows(show_ids, token) when is_list(show_ids) do
    with :ok <- Error.validate_list(show_ids, "show_ids"),
         :ok <- validate_all_ids(show_ids, "show_ids"),
         :ok <- Error.validate_token(token),
         {:ok, response} <- Client.get("/shows?ids=#{Enum.join(show_ids, ",")}", [], token) do
      case response do
        %{"shows" => shows_list} when is_list(shows_list) ->
          shows = Enum.map(shows_list, &Show.from_map/1)
          {:ok, shows}
        _ ->
          {:error, Error.new(:unexpected_response, "Expected shows array in response", %{response: response})}
      end
    end
  end

  def get_several_shows(show_ids, _token) do
    {:error, Error.new(:invalid_type, "show_ids must be a list, got: #{inspect(show_ids)}", %{value: show_ids})}
  end

  @doc """
  Get Spotify catalog information about a show's episodes (paginated).
  https://developer.spotify.com/documentation/web-api/reference/get-shows-episodes
  """
  @spec get_show_episodes(String.t(), String.t(), keyword) :: {:ok, Paging.t()} | {:error, Error.t()}
  def get_show_episodes(show_id, token, opts \\ []) do
    with :ok <- Error.validate_id(show_id, "show_id"),
         :ok <- Error.validate_token(token) do
      query = URI.encode_query(opts)
      path = "/shows/#{show_id}/episodes" <> if(query != "", do: "?#{query}", else: "")
      case Client.get(path, [], token) do
        {:ok, paging_map} ->
          parsed_paging = Paging.from_map(paging_map, &Episode.from_map/1)
          {:ok, parsed_paging}
        {:error, error} -> {:error, error}
      end
    end
  end

  @doc """
  Get a list of the shows saved in the current Spotify user's library (paginated).
  Returns a Paging struct containing saved shows with added_at timestamps.
  https://developer.spotify.com/documentation/web-api/reference/get-users-saved-shows
  """
  @spec get_users_saved_shows(String.t(), keyword) :: {:ok, Paging.t()} | {:error, Error.t()}
  def get_users_saved_shows(token, opts \\ []) do
    with :ok <- Error.validate_token(token) do
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
        {:error, error} -> {:error, error}
      end
    end
  end

  @doc """
  Save one or more shows to the current user's library.
  https://developer.spotify.com/documentation/web-api/reference/save-shows-user
  """
  @spec save_shows_for_current_user([String.t()], String.t()) :: {:ok, any()} | {:error, Error.t()}
  def save_shows_for_current_user(show_ids, token) when is_list(show_ids) do
    with :ok <- Error.validate_list(show_ids, "show_ids"),
         :ok <- validate_all_ids(show_ids, "show_ids"),
         :ok <- Error.validate_token(token) do
      query = URI.encode_query(%{"ids" => Enum.join(show_ids, ",")})
      Client.put("/me/shows?#{query}", %{}, [], token)
    end
  end

  def save_shows_for_current_user(show_ids, _token) do
    {:error, Error.new(:invalid_type, "show_ids must be a list, got: #{inspect(show_ids)}", %{value: show_ids})}
  end

  @doc """
  Remove one or more shows from the current user's library.
  https://developer.spotify.com/documentation/web-api/reference/remove-shows-user
  """
  @spec remove_users_saved_shows([String.t()], String.t()) :: {:ok, any()} | {:error, Error.t()}
  def remove_users_saved_shows(show_ids, token) when is_list(show_ids) do
    with :ok <- Error.validate_list(show_ids, "show_ids"),
         :ok <- validate_all_ids(show_ids, "show_ids"),
         :ok <- Error.validate_token(token) do
      query = URI.encode_query(%{"ids" => Enum.join(show_ids, ",")})
      Client.delete("/me/shows?#{query}", [], token)
    end
  end

  def remove_users_saved_shows(show_ids, _token) do
    {:error, Error.new(:invalid_type, "show_ids must be a list, got: #{inspect(show_ids)}", %{value: show_ids})}
  end

  @doc """
  Check if one or more shows are saved in the current user's library.
  Returns a list of booleans corresponding to the show IDs.
  https://developer.spotify.com/documentation/web-api/reference/check-users-saved-shows
  """
  @spec check_users_saved_shows([String.t()], String.t()) :: {:ok, [boolean()]} | {:error, Error.t()}
  def check_users_saved_shows(show_ids, token) when is_list(show_ids) do
    with :ok <- Error.validate_list(show_ids, "show_ids"),
         :ok <- validate_all_ids(show_ids, "show_ids"),
         :ok <- Error.validate_token(token) do
      query = URI.encode_query(%{"ids" => Enum.join(show_ids, ",")})
      Client.get("/me/shows/contains?#{query}", [], token)
    end
  end

  def check_users_saved_shows(show_ids, _token) do
    {:error, Error.new(:invalid_type, "show_ids must be a list, got: #{inspect(show_ids)}", %{value: show_ids})}
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
end
