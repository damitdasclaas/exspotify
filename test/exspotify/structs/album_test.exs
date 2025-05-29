defmodule Exspotify.Structs.AlbumTest do
  use ExUnit.Case
  alias Exspotify.Structs.{Album, Artist, Image, ExternalUrls, ExternalIds}

  describe "from_map/1" do
    test "creates Album from complete API response" do
      album_map = %{
        "id" => "album123",
        "name" => "Test Album",
        "type" => "album",
        "uri" => "spotify:album:album123",
        "href" => "https://api.spotify.com/v1/albums/album123",
        "album_type" => "album",
        "total_tracks" => 12,
        "release_date" => "2023-01-15",
        "release_date_precision" => "day",
        "label" => "Test Records",
        "popularity" => 85,
        "available_markets" => ["US", "CA", "GB"],
        "genres" => ["rock", "alternative"],
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
        ],
        "images" => [
          %{
            "url" => "https://i.scdn.co/image/large.jpg",
            "height" => 640,
            "width" => 640
          },
          %{
            "url" => "https://i.scdn.co/image/medium.jpg",
            "height" => 300,
            "width" => 300
          }
        ],
        "external_urls" => %{
          "spotify" => "https://open.spotify.com/album/album123"
        },
        "external_ids" => %{
          "upc" => "123456789012",
          "ean" => "1234567890123"
        }
      }

      result = Album.from_map(album_map)

      # Test required fields
      assert result.id == "album123"
      assert result.name == "Test Album"
      assert result.type == "album"
      assert result.uri == "spotify:album:album123"

      # Test album-specific fields
      assert result.album_type == "album"
      assert result.total_tracks == 12
      assert result.release_date == "2023-01-15"
      assert result.label == "Test Records"
      assert result.popularity == 85

      # Test arrays
      assert result.available_markets == ["US", "CA", "GB"]
      assert result.genres == ["rock", "alternative"]

      # Test nested artists array - this is where bugs often occur
      assert is_list(result.artists)
      assert length(result.artists) == 2
      assert %Artist{} = hd(result.artists)
      assert hd(result.artists).name == "Main Artist"
      assert Enum.at(result.artists, 1).name == "Featured Artist"

      # Test nested images array - common source of errors
      assert is_list(result.images)
      assert length(result.images) == 2
      assert %Image{} = hd(result.images)
      assert hd(result.images).height == 640
      assert Enum.at(result.images, 1).height == 300

      # Test nested external objects
      assert %ExternalUrls{} = result.external_urls
      assert result.external_urls.spotify == "https://open.spotify.com/album/album123"

      assert %ExternalIds{} = result.external_ids
      assert result.external_ids.upc == "123456789012"
      assert result.external_ids.ean == "1234567890123"
    end

    test "accepts missing fields and sets them to nil" do
      # Test actual behavior: missing fields become nil
      minimal_album = %{
        "id" => "album123",
        "name" => "Minimal Album",
        "type" => "album",
        "uri" => "spotify:album:album123"
        # All other fields missing
      }

      result = Album.from_map(minimal_album)

      assert result.id == "album123"
      assert result.name == "Minimal Album"
      assert result.type == "album"
      assert result.uri == "spotify:album:album123"

      # Missing fields should be nil
      assert result.album_type == nil
      assert result.artists == nil
      assert result.images == nil
      assert result.external_urls == nil
      assert result.popularity == nil
    end

    test "handles malformed artists gracefully by setting to nil" do
      # When artists array contains invalid data, the parse now handles it gracefully
      album_map = %{
        "id" => "album123",
        "name" => "Test Album",
        "type" => "album",
        "uri" => "spotify:album:album123",
        "artists" => "not_an_array"  # Invalid data type
      }

      # This now handles the error gracefully by setting artists to nil
      result = Album.from_map(album_map)
      assert result.artists == nil
    end

    test "validates required fields and raises error when missing" do
      # Test that missing required fields raise ArgumentError
      incomplete_album = %{
        "name" => "Missing ID Album",
        "type" => "album",
        "uri" => "spotify:album:missing123"
        # Missing "id" field
      }

      assert_raise ArgumentError, "Album missing required fields: id, name, type, or uri", fn ->
        Album.from_map(incomplete_album)
      end
    end

    test "catches real bug when artist within array is malformed" do
      # This test checks validation within nested Artist structs
      album_map = %{
        "id" => "album123",
        "name" => "Test Album",
        "type" => "album",
        "uri" => "spotify:album:album123",
        "artists" => [
          %{
            "id" => "artist1",
            "name" => "Valid Artist",
            "type" => "artist",
            "uri" => "spotify:artist:artist1"
          },
          %{
            # This artist has missing required fields
            "name" => "Invalid Artist"
            # Missing id, type, uri
          }
        ]
      }

      # This should now raise an error for the invalid Artist
      assert_raise ArgumentError, "Artist missing required fields: id, name, type, or uri", fn ->
        Album.from_map(album_map)
      end
    end

    test "catches real bug when image within array is malformed" do
      album_map = %{
        "id" => "album123",
        "name" => "Test Album",
        "type" => "album",
        "uri" => "spotify:album:album123",
        "images" => [
          %{
            "url" => "https://valid.image.jpg",
            "height" => 640,
            "width" => 640
          },
          %{
            # Missing required URL field
            "height" => 300,
            "width" => 300
          }
        ]
      }

      # This should now raise an error for the invalid Image
      assert_raise ArgumentError, "Image missing required URL field or URL is not a string", fn ->
        Album.from_map(album_map)
      end
    end

    test "handles empty nested arrays correctly" do
      album_map = %{
        "id" => "album123",
        "name" => "Empty Album",
        "type" => "album",
        "uri" => "spotify:album:album123",
        "artists" => [],
        "images" => [],
        "genres" => [],
        "available_markets" => []
      }

      result = Album.from_map(album_map)

      assert result.artists == []
      assert result.images == []
      assert result.genres == []
      assert result.available_markets == []
    end

    test "handles nil nested objects without crashing" do
      album_map = %{
        "id" => "album123",
        "name" => "Minimal Album",
        "type" => "album",
        "uri" => "spotify:album:album123",
        "artists" => nil,
        "images" => nil,
        "external_urls" => nil,
        "external_ids" => nil
      }

      result = Album.from_map(album_map)

      assert result.artists == nil
      assert result.images == nil
      assert result.external_urls == nil
      assert result.external_ids == nil
    end

    test "catches type inconsistencies in numeric fields" do
      # Test that reveals if we get unexpected data types
      album_map = %{
        "id" => "album123",
        "name" => "Numbers Album",
        "type" => "album",
        "uri" => "spotify:album:album123",
        "total_tracks" => "not_a_number",  # String instead of integer
        "popularity" => "85"  # String instead of integer
      }

      result = Album.from_map(album_map)

      # These should now be converted to nil due to type validation
      assert result.total_tracks == nil
      assert result.popularity == nil
    end
  end
end
