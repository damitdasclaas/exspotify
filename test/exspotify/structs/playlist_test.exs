defmodule Exspotify.Structs.PlaylistTest do
  use ExUnit.Case
  alias Exspotify.Structs.{Playlist, ExternalUrls, Image, User}

  describe "from_map/1" do
    test "creates Playlist from complete API response" do
      playlist_map = %{
        "id" => "playlist123",
        "name" => "My Awesome Playlist",
        "type" => "playlist",
        "uri" => "spotify:playlist:playlist123",
        "href" => "https://api.spotify.com/v1/playlists/playlist123",
        "collaborative" => false,
        "description" => "The best songs ever",
        "public" => true,
        "snapshot_id" => "MTMsOTU0MDUzODQ3MTJkMjRkN",
        "external_urls" => %{
          "spotify" => "https://open.spotify.com/playlist/playlist123"
        },
        "images" => [
          %{
            "url" => "https://i.scdn.co/image/playlist_large.jpg",
            "height" => 640,
            "width" => 640
          }
        ],
        "owner" => %{
          "id" => "user123",
          "type" => "user",
          "uri" => "spotify:user:user123",
          "display_name" => "Test User"
        },
        "tracks" => %{
          "href" => "https://api.spotify.com/v1/playlists/playlist123/tracks",
          "total" => 25
        }
      }

      result = Playlist.from_map(playlist_map)

      # Test required fields
      assert result.id == "playlist123"
      assert result.name == "My Awesome Playlist"
      assert result.type == "playlist"
      assert result.uri == "spotify:playlist:playlist123"

      # Test optional fields
      assert result.collaborative == false
      assert result.description == "The best songs ever"
      assert result.public == true
      assert result.snapshot_id == "MTMsOTU0MDUzODQ3MTJkMjRkN"

      # Test nested external_urls
      assert %ExternalUrls{} = result.external_urls
      assert result.external_urls.spotify == "https://open.spotify.com/playlist/playlist123"

      # Test nested images array
      assert is_list(result.images)
      assert length(result.images) == 1
      assert %Image{} = hd(result.images)
      assert hd(result.images).url == "https://i.scdn.co/image/playlist_large.jpg"

      # Test nested owner
      assert %User{} = result.owner
      assert result.owner.id == "user123"
      assert result.owner.display_name == "Test User"

      # Test tracks object (kept as map)
      assert is_map(result.tracks)
      assert result.tracks["total"] == 25
    end

    test "creates Playlist with minimal required fields" do
      playlist_map = %{
        "id" => "minimal123",
        "name" => "Minimal Playlist",
        "type" => "playlist",
        "uri" => "spotify:playlist:minimal123"
      }

      result = Playlist.from_map(playlist_map)

      assert result.id == "minimal123"
      assert result.name == "Minimal Playlist"
      assert result.type == "playlist"
      assert result.uri == "spotify:playlist:minimal123"

      # Optional fields should be nil
      assert result.collaborative == nil
      assert result.description == nil
      assert result.external_urls == nil
      assert result.images == nil
      assert result.owner == nil
    end

    test "provides sensible defaults for missing required fields" do
      incomplete_playlist = %{
        "name" => "Missing Fields Playlist",
        "type" => "playlist"
        # Missing "id" and "uri"
      }

      result = Playlist.from_map(incomplete_playlist)

      # Now provides sensible defaults instead of raising errors
      assert result.id == "unknown"
      assert result.uri == ""
      assert result.name == "Missing Fields Playlist"
      assert result.type == "playlist"
    end

    test "handles malformed images gracefully" do
      playlist_map = %{
        "id" => "playlist123",
        "name" => "Test Playlist",
        "type" => "playlist",
        "uri" => "spotify:playlist:playlist123",
        "images" => "not_an_array"  # Invalid data type
      }

      result = Playlist.from_map(playlist_map)

      # Should now handle gracefully by setting images to nil
      assert result.images == nil
    end

    test "handles empty arrays correctly" do
      playlist_map = %{
        "id" => "playlist123",
        "name" => "Empty Playlist",
        "type" => "playlist",
        "uri" => "spotify:playlist:playlist123",
        "images" => []
      }

      result = Playlist.from_map(playlist_map)

      assert result.images == []
    end

    test "handles nil nested objects gracefully" do
      playlist_map = %{
        "id" => "playlist123",
        "name" => "Test Playlist",
        "type" => "playlist",
        "uri" => "spotify:playlist:playlist123",
        "external_urls" => nil,
        "images" => nil,
        "owner" => nil
      }

      result = Playlist.from_map(playlist_map)

      assert result.external_urls == nil
      assert result.images == nil
      assert result.owner == nil
    end

    test "reveals current validation gaps" do
      # This test documents what happens with invalid data types for non-required fields
      invalid_playlist = %{
        "id" => "playlist123",  # Valid required field
        "name" => "Test Playlist",  # Valid required field
        "type" => "playlist",  # Valid required field
        "uri" => "spotify:playlist:playlist123",  # Valid required field
        "collaborative" => "yes",  # String instead of boolean
        "public" => "no"  # String instead of boolean
      }

      result = Playlist.from_map(invalid_playlist)

      # Documents current behavior - no type validation for boolean fields
      assert result.collaborative == "yes"
      assert result.public == "no"

      # This shows we need better validation for boolean fields
      refute is_boolean(result.collaborative)
      refute is_boolean(result.public)
    end
  end
end
