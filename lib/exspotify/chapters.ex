defmodule Exspotify.Chapters do
  @moduledoc """
  Provides functions for interacting with the Chapters endpoints of the Spotify Web API.
  See: https://developer.spotify.com/documentation/web-api/reference/chapters
  """

  alias Exspotify.Client
  alias Exspotify.Structs.Chapter

  @doc """
  Get Spotify catalog information for a single chapter by its unique Spotify ID.
  https://developer.spotify.com/documentation/web-api/reference/get-chapter
  """
  @spec get_chapter(String.t(), String.t()) :: {:ok, Chapter.t()} | {:error, any()}
  def get_chapter(chapter_id, token) do
    case Client.get("/chapters/#{chapter_id}", [], token) do
      {:ok, chapter_map} -> {:ok, Chapter.from_map(chapter_map)}
      error -> error
    end
  end

  @doc """
  Get Spotify catalog information for several chapters based on their Spotify IDs.
  https://developer.spotify.com/documentation/web-api/reference/get-several-chapters
  """
  @spec get_several_chapters([String.t()], String.t()) :: {:ok, [Chapter.t()]} | {:error, any()}
  def get_several_chapters(chapter_ids, token) when is_list(chapter_ids) do
    ids_param = Enum.join(chapter_ids, ",")
    case Client.get("/chapters?ids=#{ids_param}", [], token) do
      {:ok, %{"chapters" => chapters_list}} ->
        chapters = Enum.map(chapters_list, &Chapter.from_map/1)
        {:ok, chapters}
      error -> error
    end
  end
end
