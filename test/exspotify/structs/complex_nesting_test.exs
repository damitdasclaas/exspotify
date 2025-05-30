defmodule Exspotify.Structs.ComplexNestingTest do
  use ExUnit.Case
  alias Exspotify.Structs.{Track, Album, Artist, Image, ExternalUrls, Paging}

  describe "complex object nesting" do
    test "handles deeply nested Track→Album→Artists→Images chain" do
      # This tests the full parsing chain that's commonly used in API responses
      complex_track = %{
        "id" => "track123",
        "name" => "Complex Track",
        "type" => "track",
        "uri" => "spotify:track:track123",
        "album" => %{
          "id" => "album123",
          "name" => "Complex Album",
          "type" => "album",
          "uri" => "spotify:album:album123",
          "artists" => [
            %{
              "id" => "artist1",
              "name" => "Main Artist",
              "type" => "artist",
              "uri" => "spotify:artist:artist1",
              "images" => [
                %{
                  "url" => "https://artist1.image.jpg",
                  "height" => 640,
                  "width" => 640
                },
                %{
                  "url" => "https://artist1.small.jpg",
                  "height" => 64,
                  "width" => 64
                }
              ],
              "external_urls" => %{
                "spotify" => "https://open.spotify.com/artist/artist1"
              }
            },
            %{
              "id" => "artist2",
              "name" => "Featured Artist",
              "type" => "artist",
              "uri" => "spotify:artist:artist2",
              "images" => []  # Empty array
            }
          ],
          "images" => [
            %{
              "url" => "https://album.cover.jpg",
              "height" => 640,
              "width" => 640
            }
          ],
          "external_urls" => %{
            "spotify" => "https://open.spotify.com/album/album123"
          }
        },
        "artists" => [
          %{
            "id" => "artist1",
            "name" => "Main Artist",
            "type" => "artist",
            "uri" => "spotify:artist:artist1"
          }
        ]
      }

      result = Track.from_map(complex_track)

      # Test track level
      assert %Track{} = result
      assert result.name == "Complex Track"

      # Test album level
      assert %Album{} = result.album
      assert result.album.name == "Complex Album"

      # Test album artists (deeper nesting)
      assert is_list(result.album.artists)
      assert length(result.album.artists) == 2

      first_album_artist = hd(result.album.artists)
      assert %Artist{} = first_album_artist
      assert first_album_artist.name == "Main Artist"

      # Test artist images (deepest level)
      assert is_list(first_album_artist.images)
      assert length(first_album_artist.images) == 2
      assert %Image{} = hd(first_album_artist.images)
      assert hd(first_album_artist.images).height == 640

      # Test external URLs at artist level
      assert %ExternalUrls{} = first_album_artist.external_urls
      assert first_album_artist.external_urls.spotify == "https://open.spotify.com/artist/artist1"

      # Test second artist with empty images
      second_album_artist = Enum.at(result.album.artists, 1)
      assert second_album_artist.images == []

      # Test album images
      assert is_list(result.album.images)
      assert length(result.album.images) == 1

      # Test track artists (separate from album artists)
      assert is_list(result.artists)
      assert length(result.artists) == 1
      assert hd(result.artists).name == "Main Artist"
    end

    test "handles Paging with nested Track objects containing Albums" do
      # Tests pagination with complex objects - common in search results
      paging_with_tracks = %{
        "limit" => 2,
        "offset" => 0,
        "total" => 100,
        "items" => [
          %{
            "id" => "track1",
            "name" => "First Track",
            "type" => "track",
            "uri" => "spotify:track:track1",
            "album" => %{
              "id" => "album1",
              "name" => "First Album",
              "type" => "album",
              "uri" => "spotify:album:album1",
              "images" => [
                %{"url" => "https://album1.jpg", "height" => 300}
              ]
            }
          },
          %{
            "id" => "track2",
            "name" => "Second Track",
            "type" => "track",
            "uri" => "spotify:track:track2",
            "album" => %{
              "id" => "album2",
              "name" => "Second Album",
              "type" => "album",
              "uri" => "spotify:album:album2",
              "images" => []
            }
          }
        ]
      }

      result = Paging.from_map(paging_with_tracks, &Track.from_map/1)

      assert %Paging{} = result
      assert result.total == 100
      assert length(result.items) == 2

      # Test first track and its album
      first_track = hd(result.items)
      assert %Track{} = first_track
      assert first_track.name == "First Track"
      assert %Album{} = first_track.album
      assert first_track.album.name == "First Album"
      assert length(first_track.album.images) == 1

      # Test second track with empty album images
      second_track = Enum.at(result.items, 1)
      assert second_track.album.images == []
    end

    test "exposes real parsing failures with malformed deep nesting" do
      # This test reveals actual bugs that could occur with API inconsistencies
      malformed_track = %{
        "id" => "track123",
        "name" => "Problematic Track",
        "type" => "track",
        "uri" => "spotify:track:track123",
        "album" => %{
          "id" => "album123",
          "name" => "Problematic Album",
          "type" => "album",
          "uri" => "spotify:album:album123",
          "artists" => [
            %{
              "id" => "artist1",
              "name" => "Good Artist",
              "type" => "artist",
              "uri" => "spotify:artist:artist1"
            },
            %{
              # This artist is missing required fields - should get defaults
              "name" => "Incomplete Artist"
              # Missing id, type, uri
            }
          ],
          "images" => [
            %{
              "url" => "https://good.image.jpg",
              "height" => 640,
              "width" => 640
            },
            %{
              # This image is missing required URL - should get default
              "height" => 300,
              "width" => 300
            }
          ]
        }
      }

      # This should not crash but handle gracefully with defaults
      result = Track.from_map(malformed_track)

      assert %Track{} = result
      assert %Album{} = result.album

      # Should have both artists with defaults applied
      assert length(result.album.artists) == 2
      incomplete_artist = Enum.at(result.album.artists, 1)
      assert incomplete_artist.id == "unknown"  # Default
      assert incomplete_artist.type == "artist"  # Default
      assert incomplete_artist.uri == ""  # Default

      # Should have both images with defaults applied
      assert length(result.album.images) == 2
      incomplete_image = Enum.at(result.album.images, 1)
      assert incomplete_image.url == ""  # Default
      assert incomplete_image.height == 300
    end
  end
end
