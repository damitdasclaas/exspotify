defmodule Exspotify.Structs.Episode do
  @moduledoc """
  Represents an episode object from Spotify API.
  """

  alias Exspotify.Structs.{ExternalUrls, Image, ResumePoint, Show}

  @enforce_keys [:id, :name, :type, :uri]
  defstruct [
    :id,
    :name,
    :type,
    :uri,
    :href,
    :audio_preview_url,
    :description,
    :html_description,
    :duration_ms,
    :explicit,
    :external_urls,
    :images,
    :is_externally_hosted,
    :is_playable,
    :language,
    :languages,
    :release_date,
    :release_date_precision,
    :resume_point,
    :restrictions,
    :show
  ]

  @type t :: %__MODULE__{
    id: String.t(),
    name: String.t(),
    type: String.t(),
    uri: String.t(),
    href: String.t() | nil,
    audio_preview_url: String.t() | nil,
    description: String.t() | nil,
    html_description: String.t() | nil,
    duration_ms: integer() | nil,
    explicit: boolean() | nil,
    external_urls: ExternalUrls.t() | nil,
    images: [Image.t()] | nil,
    is_externally_hosted: boolean() | nil,
    is_playable: boolean() | nil,
    language: String.t() | nil,
    languages: [String.t()] | nil,
    release_date: String.t() | nil,
    release_date_precision: String.t() | nil,
    resume_point: ResumePoint.t() | nil,
    restrictions: map() | nil,
    show: Show.t() | nil
  }

  @doc """
  Creates an Episode struct from a map (typically from JSON).
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
      description: Map.get(map, "description"),
      html_description: Map.get(map, "html_description"),
      duration_ms: Map.get(map, "duration_ms"),
      explicit: Map.get(map, "explicit"),
      external_urls: parse_external_urls(Map.get(map, "external_urls")),
      images: parse_images(Map.get(map, "images")),
      is_externally_hosted: Map.get(map, "is_externally_hosted"),
      is_playable: Map.get(map, "is_playable"),
      language: Map.get(map, "language"),
      languages: Map.get(map, "languages"),
      release_date: Map.get(map, "release_date"),
      release_date_precision: Map.get(map, "release_date_precision"),
      resume_point: parse_resume_point(Map.get(map, "resume_point")),
      restrictions: Map.get(map, "restrictions"),
      show: parse_show(Map.get(map, "show"))
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

  defp parse_show(nil), do: nil
  defp parse_show(map), do: Show.from_map(map)
end
