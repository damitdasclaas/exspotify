defmodule Exspotify.Chapters do
  @moduledoc """
  Provides functions for interacting with the Chapters endpoints of the Spotify Web API.
  See: https://developer.spotify.com/documentation/web-api/reference/chapters
  """

  alias Exspotify.Client

  @doc """
  Get Spotify catalog information for a single chapter by its unique Spotify ID.
  https://developer.spotify.com/documentation/web-api/reference/get-chapter
  """
  @spec get_chapter(String.t(), String.t()) :: any
  def get_chapter(chapter_id, token) do
    Client.get("/chapters/#{chapter_id}", [], token)
  end

  @doc """
  Get Spotify catalog information for several chapters based on their Spotify IDs.
  https://developer.spotify.com/documentation/web-api/reference/get-several-chapters
  """
  @spec get_several_chapters([String.t()], String.t()) :: any
  def get_several_chapters(chapter_ids, token) when is_list(chapter_ids) do
    ids_param = Enum.join(chapter_ids, ",")
    Client.get("/chapters?ids=#{ids_param}", [], token)
  end
end
