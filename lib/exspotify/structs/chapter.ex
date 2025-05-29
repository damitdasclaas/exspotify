defmodule Exspotify.Structs.Chapter do
  @moduledoc """
  Represents a chapter object from Spotify API.
  """

  alias Exspotify.Structs.{Audiobook, ExternalUrls, Image, ResumePoint}

  @enforce_keys [:id, :name, :type, :uri]
  defstruct [
    :id,
    :name,
    :type,
    :uri,
    :href,
    :audio_preview_url,
    :available_markets,
    :chapter_number,
    :description,
    :html_description,
    :duration_ms,
    :explicit,
    :external_urls,
    :images,
    :is_playable,
    :languages,
    :release_date,
    :release_date_precision,
    :resume_point,
    :restrictions,
    :audiobook
  ]

  @type t :: %__MODULE__{
    id: String.t(),
    name: String.t(),
    type: String.t(),
    uri: String.t(),
    href: String.t() | nil,
    audio_preview_url: String.t() | nil,
    available_markets: [String.t()] | nil,
    chapter_number: integer() | nil,
    description: String.t() | nil,
    html_description: String.t() | nil,
    duration_ms: integer() | nil,
    explicit: boolean() | nil,
    external_urls: ExternalUrls.t() | nil,
    images: [Image.t()] | nil,
    is_playable: boolean() | nil,
    languages: [String.t()] | nil,
    release_date: String.t() | nil,
    release_date_precision: String.t() | nil,
    resume_point: ResumePoint.t() | nil,
    restrictions: map() | nil,
    audiobook: Audiobook.t() | nil
  }

  @doc """
  Creates a Chapter struct from a map (typically from JSON).
  """
  @spec from_map(map()) :: t()
  def from_map(map) when is_map(map) do
    %__MODULE__{
      id: Map.get(map, "id"),
      name: Map.get(map, "name"),
      type: Map.get(map, "type"),
      uri: Map.get(map, "uri"),
      href: Map.get(map, "href"),
      audio_preview_url: Map.get(map, "audio_preview_url"),
      available_markets: Map.get(map, "available_markets"),
      chapter_number: Map.get(map, "chapter_number"),
      description: Map.get(map, "description"),
      html_description: Map.get(map, "html_description"),
      duration_ms: Map.get(map, "duration_ms"),
      explicit: Map.get(map, "explicit"),
      external_urls: parse_external_urls(Map.get(map, "external_urls")),
      images: parse_images(Map.get(map, "images")),
      is_playable: Map.get(map, "is_playable"),
      languages: Map.get(map, "languages"),
      release_date: Map.get(map, "release_date"),
      release_date_precision: Map.get(map, "release_date_precision"),
      resume_point: parse_resume_point(Map.get(map, "resume_point")),
      restrictions: Map.get(map, "restrictions"),
      audiobook: parse_audiobook(Map.get(map, "audiobook"))
    }
  end

  defp parse_external_urls(nil), do: nil
  defp parse_external_urls(map), do: ExternalUrls.from_map(map)

  defp parse_images(nil), do: nil
  defp parse_images(images) when is_list(images) do
    Enum.map(images, &Image.from_map/1)
  end

  defp parse_resume_point(nil), do: nil
  defp parse_resume_point(map), do: ResumePoint.from_map(map)

  defp parse_audiobook(nil), do: nil
  defp parse_audiobook(map), do: Audiobook.from_map(map)
end
