defmodule Exspotify.Artists do
  @moduledoc """
  Provides functions for interacting with the Artists endpoints of the Spotify Web API.
  See: https://developer.spotify.com/documentation/web-api/reference/artists

  Note: The 'related artists' endpoint is deprecated and not included in this module.
  """

  alias Exspotify.{Client, Error}
  alias Exspotify.Structs.{Artist, Album, Track, Paging}

  @doc """
  Get Spotify catalog information for a single artist by their unique Spotify ID.
  https://developer.spotify.com/documentation/web-api/reference/get-artist
  """
  @spec get_artist(String.t(), String.t()) :: {:ok, Artist.t()} | {:error, Error.t()}
  def get_artist(artist_id, token) do
    with :ok <- Error.validate_id(artist_id, "artist_id"),
         :ok <- Error.validate_token(token),
         {:ok, artist_map} <- Client.get("/artists/#{artist_id}", [], token) do
      {:ok, Artist.from_map(artist_map)}
    end
  end

  @doc """
  Get Spotify catalog information for several artists based on their Spotify IDs.
  https://developer.spotify.com/documentation/web-api/reference/get-several-artists
  """
  @spec get_several_artists([String.t()], String.t()) :: {:ok, [Artist.t()]} | {:error, Error.t()}
  def get_several_artists(artist_ids, token) when is_list(artist_ids) do
    with :ok <- Error.validate_list(artist_ids, "artist_ids"),
         :ok <- validate_all_ids(artist_ids, "artist_ids"),
         :ok <- Error.validate_token(token),
         {:ok, response} <- Client.get("/artists?ids=#{Enum.join(artist_ids, ",")}", [], token) do
      case response do
        %{"artists" => artists_list} when is_list(artists_list) ->
          artists = Enum.map(artists_list, &Artist.from_map/1)
          {:ok, artists}
        _ ->
          {:error, Error.new(:unexpected_response, "Expected artists array in response", %{response: response})}
      end
    end
  end

  def get_several_artists(artist_ids, _token) do
    {:error, Error.new(:invalid_type, "artist_ids must be a list, got: #{inspect(artist_ids)}", %{value: artist_ids})}
  end

  @doc """
  Get Spotify catalog information about an artist's albums (paginated).
  https://developer.spotify.com/documentation/web-api/reference/get-an-artists-albums
  """
  @spec get_artist_albums(String.t(), String.t(), keyword) :: {:ok, Paging.t()} | {:error, Error.t()}
  def get_artist_albums(artist_id, token, opts \\ []) do
    with :ok <- Error.validate_id(artist_id, "artist_id"),
         :ok <- Error.validate_token(token) do
      query = URI.encode_query(opts)
      path = "/artists/#{artist_id}/albums" <> if(query != "", do: "?#{query}", else: "")
      case Client.get(path, [], token) do
        {:ok, paging_map} ->
          parsed_paging = Paging.from_map(paging_map, &Album.from_map/1)
          {:ok, parsed_paging}
        {:error, error} -> {:error, error}
      end
    end
  end

  @doc """
  Get Spotify catalog information about an artist's top tracks by market.
  Returns a list of the artist's top tracks.
  https://developer.spotify.com/documentation/web-api/reference/get-an-artists-top-tracks
  """
  @spec get_artist_top_tracks(String.t(), String.t(), String.t()) :: {:ok, [Track.t()]} | {:error, Error.t()}
  def get_artist_top_tracks(artist_id, token, market) do
    with :ok <- Error.validate_id(artist_id, "artist_id"),
         :ok <- Error.validate_token(token),
         :ok <- Error.validate_id(market, "market") do
      case Client.get("/artists/#{artist_id}/top-tracks?market=#{market}", [], token) do
        {:ok, %{"tracks" => tracks_list}} when is_list(tracks_list) ->
          tracks = Enum.map(tracks_list, &Track.from_map/1)
          {:ok, tracks}
        {:ok, response} ->
          {:error, Error.new(:unexpected_response, "Expected tracks array in response", %{response: response})}
        {:error, error} -> {:error, error}
      end
    end
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
