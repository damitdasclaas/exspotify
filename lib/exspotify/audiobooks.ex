defmodule Exspotify.Audiobooks do
  @moduledoc """
  Provides functions for interacting with the Audiobooks endpoints of the Spotify Web API.
  See: https://developer.spotify.com/documentation/web-api/reference/audiobooks
  """

  alias Exspotify.Client
  alias Exspotify.Structs.{Audiobook, Chapter, Paging}

  @doc """
  Get Spotify catalog information for a single audiobook by its unique Spotify ID.
  https://developer.spotify.com/documentation/web-api/reference/get-audiobook
  """
  @spec get_audiobook(String.t(), String.t()) :: {:ok, Audiobook.t()} | {:error, any()}
  def get_audiobook(audiobook_id, token) do
    case Client.get("/audiobooks/#{audiobook_id}", [], token) do
      {:ok, audiobook_map} -> {:ok, Audiobook.from_map(audiobook_map)}
      error -> error
    end
  end

  @doc """
  Get Spotify catalog information for several audiobooks based on their Spotify IDs.
  https://developer.spotify.com/documentation/web-api/reference/get-several-audiobooks
  """
  @spec get_several_audiobooks([String.t()], String.t()) :: {:ok, [Audiobook.t()]} | {:error, any()}
  def get_several_audiobooks(audiobook_ids, token) when is_list(audiobook_ids) do
    ids_param = Enum.join(audiobook_ids, ",")
    case Client.get("/audiobooks?ids=#{ids_param}", [], token) do
      {:ok, %{"audiobooks" => audiobooks_list}} ->
        audiobooks = Enum.map(audiobooks_list, &Audiobook.from_map/1)
        {:ok, audiobooks}
      error -> error
    end
  end

  @doc """
  Get Spotify catalog information about an audiobook's chapters (paginated).
  https://developer.spotify.com/documentation/web-api/reference/get-audiobook-chapters
  """
  @spec get_audiobook_chapters(String.t(), String.t(), keyword) :: {:ok, Paging.t()} | {:error, any()}
  def get_audiobook_chapters(audiobook_id, token, opts \\ []) do
    query = URI.encode_query(opts)
    path = "/audiobooks/#{audiobook_id}/chapters" <> if(query != "", do: "?#{query}", else: "")
    case Client.get(path, [], token) do
      {:ok, paging_map} ->
        parsed_paging = Paging.from_map(paging_map, &Chapter.from_map/1)
        {:ok, parsed_paging}
      error -> error
    end
  end

  @doc """
  Get a list of the audiobooks saved in the current Spotify user's library (paginated).
  Returns a Paging struct containing saved audiobooks with added_at timestamps.
  https://developer.spotify.com/documentation/web-api/reference/get-users-saved-audiobooks
  """
  @spec get_users_saved_audiobooks(String.t(), keyword) :: {:ok, Paging.t()} | {:error, any()}
  def get_users_saved_audiobooks(token, opts \\ []) do
    query = URI.encode_query(opts)
    path = "/me/audiobooks" <> if(query != "", do: "?#{query}", else: "")
    case Client.get(path, [], token) do
      {:ok, paging_map} ->
        # Parse items as maps with added_at and audiobook fields
        parsed_paging = Paging.from_map(paging_map, fn item ->
          %{
            "added_at" => item["added_at"],
            "audiobook" => Audiobook.from_map(item["audiobook"])
          }
        end)
        {:ok, parsed_paging}
      error -> error
    end
  end

  @doc """
  Save one or more audiobooks to the current user's library.
  https://developer.spotify.com/documentation/web-api/reference/save-audiobooks-user
  """
  @spec save_audiobooks_for_current_user([String.t()], String.t()) :: {:ok, any()} | {:error, any()}
  def save_audiobooks_for_current_user(audiobook_ids, token) when is_list(audiobook_ids) do
    query = URI.encode_query(%{"ids" => Enum.join(audiobook_ids, ",")})
    Client.put("/me/audiobooks?#{query}", %{}, [], token)
  end

  @doc """
  Remove one or more audiobooks from the current user's library.
  https://developer.spotify.com/documentation/web-api/reference/remove-audiobooks-user
  """
  @spec remove_users_saved_audiobooks([String.t()], String.t()) :: {:ok, any()} | {:error, any()}
  def remove_users_saved_audiobooks(audiobook_ids, token) when is_list(audiobook_ids) do
    query = URI.encode_query(%{"ids" => Enum.join(audiobook_ids, ",")})
    Client.delete("/me/audiobooks?#{query}", [], token)
  end

  @doc """
  Check if one or more audiobooks are saved in the current user's library.
  Returns a list of booleans corresponding to the audiobook IDs.
  https://developer.spotify.com/documentation/web-api/reference/check-users-saved-audiobooks
  """
  @spec check_users_saved_audiobooks([String.t()], String.t()) :: {:ok, [boolean()]} | {:error, any()}
  def check_users_saved_audiobooks(audiobook_ids, token) when is_list(audiobook_ids) do
    query = URI.encode_query(%{"ids" => Enum.join(audiobook_ids, ",")})
    Client.get("/me/audiobooks/contains?#{query}", [], token)
  end
end
