defmodule Exspotify.Chapters do
  @moduledoc """
  Provides functions for interacting with the Chapters endpoints of the Spotify Web API.
  See: https://developer.spotify.com/documentation/web-api/reference/chapters
  """

  alias Exspotify.{Client, Error}
  alias Exspotify.Structs.Chapter

  @doc """
  Get Spotify catalog information for a single chapter by its unique Spotify ID.
  https://developer.spotify.com/documentation/web-api/reference/get-chapter
  """
  @spec get_chapter(String.t(), String.t()) :: {:ok, Chapter.t()} | {:error, Error.t()}
  def get_chapter(chapter_id, token) do
    with :ok <- Error.validate_id(chapter_id, "chapter_id"),
         :ok <- Error.validate_token(token),
         {:ok, chapter_map} <- Client.get("/chapters/#{chapter_id}", [], token) do
      {:ok, Chapter.from_map(chapter_map)}
    end
  end

  @doc """
  Get Spotify catalog information for several chapters based on their Spotify IDs.
  https://developer.spotify.com/documentation/web-api/reference/get-several-chapters
  """
  @spec get_several_chapters([String.t()], String.t()) :: {:ok, [Chapter.t()]} | {:error, Error.t()}
  def get_several_chapters(chapter_ids, token) when is_list(chapter_ids) do
    with :ok <- Error.validate_list(chapter_ids, "chapter_ids"),
         :ok <- validate_all_ids(chapter_ids, "chapter_ids"),
         :ok <- Error.validate_token(token),
         {:ok, response} <- Client.get("/chapters?ids=#{Enum.join(chapter_ids, ",")}", [], token) do
      case response do
        %{"chapters" => chapters_list} when is_list(chapters_list) ->
          chapters = Enum.map(chapters_list, &Chapter.from_map/1)
          {:ok, chapters}
        _ ->
          {:error, Error.new(:unexpected_response, "Expected chapters array in response", %{response: response})}
      end
    end
  end

  def get_several_chapters(chapter_ids, _token) do
    {:error, Error.new(:invalid_type, "chapter_ids must be a list, got: #{inspect(chapter_ids)}", %{value: chapter_ids})}
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
