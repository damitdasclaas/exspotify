defmodule Exspotify.Structs.TrackTest do
  use ExUnit.Case
  alias Exspotify.Structs.{Track, Album, Artist, ExternalUrls, ExternalIds}

  describe "from_map/1" do
    test "creates Track from complete API response" do
      track_map = %{
        "id" => "track123",
        "name" => "Test Song",
        "type" => "track",
        "uri" => "spotify:track:track123",
        "href" => "https://api.spotify.com/v1/tracks/track123",
        "duration_ms" => 210000,
        "explicit" => false,
        "popularity" => 75,
        "preview_url" => "https://p.scdn.co/mp3-preview/test",
        "track_number" => 1,
        "disc_number" => 1,
        "is_local" => false,
        "album" => %{
          "id" => "album123",
          "name" => "Test Album",
          "type" => "album",
          "uri" => "spotify:album:album123"
        },
        "artists" => [
          %{
            "id" => "artist123",
            "name" => "Test Artist",
            "type" => "artist",
            "uri" => "spotify:artist:artist123"
          }
        ],
        "external_urls" => %{
          "spotify" => "https://open.spotify.com/track/track123"
        },
        "external_ids" => %{
          "isrc" => "USRC17607839"
        }
      }

      result = Track.from_map(track_map)

      # Test basic track fields
      assert result.id == "track123"
      assert result.name == "Test Song"
      assert result.type == "track"
      assert result.uri == "spotify:track:track123"
      assert result.duration_ms == 210000
      assert result.popularity == 75

      # Test nested album
      assert %Album{} = result.album
      assert result.album.id == "album123"
      assert result.album.name == "Test Album"

      # Test nested artists array
      assert is_list(result.artists)
      assert length(result.artists) == 1
      assert %Artist{} = hd(result.artists)
      assert hd(result.artists).id == "artist123"
      assert hd(result.artists).name == "Test Artist"

      # Test nested external_urls
      assert %ExternalUrls{} = result.external_urls
      assert result.external_urls.spotify == "https://open.spotify.com/track/track123"

      # Test nested external_ids
      assert %ExternalIds{} = result.external_ids
      assert result.external_ids.isrc == "USRC17607839"
    end

    test "creates Track with minimal required fields" do
      track_map = %{
        "id" => "minimal123",
        "name" => "Minimal Track",
        "type" => "track",
        "uri" => "spotify:track:minimal123"
      }

      result = Track.from_map(track_map)

      assert result.id == "minimal123"
      assert result.name == "Minimal Track"
      assert result.type == "track"
      assert result.uri == "spotify:track:minimal123"

      # Optional fields should be nil
      assert result.album == nil
      assert result.artists == nil
      assert result.duration_ms == nil
      assert result.external_urls == nil
    end

    test "handles empty artists array" do
      track_map = %{
        "id" => "track123",
        "name" => "Test Song",
        "type" => "track",
        "uri" => "spotify:track:track123",
        "artists" => []
      }

      result = Track.from_map(track_map)

      assert result.artists == []
    end

    test "handles missing nested objects gracefully" do
      track_map = %{
        "id" => "track123",
        "name" => "Test Song",
        "type" => "track",
        "uri" => "spotify:track:track123",
        "album" => nil,
        "artists" => nil,
        "external_urls" => nil
      }

      result = Track.from_map(track_map)

      assert result.album == nil
      assert result.artists == nil
      assert result.external_urls == nil
    end

    test "parses multiple artists correctly" do
      track_map = %{
        "id" => "collab123",
        "name" => "Collaboration Track",
        "type" => "track",
        "uri" => "spotify:track:collab123",
        "artists" => [
          %{
            "id" => "artist1",
            "name" => "Main Artist",
            "type" => "artist",
            "uri" => "spotify:artist:artist1"
          },
          %{
            "id" => "artist2",
            "name" => "Featured Artist",
            "type" => "artist",
            "uri" => "spotify:artist:artist2"
          }
        ]
      }

      result = Track.from_map(track_map)

      assert length(result.artists) == 2
      assert Enum.at(result.artists, 0).name == "Main Artist"
      assert Enum.at(result.artists, 1).name == "Featured Artist"
    end
  end
end
