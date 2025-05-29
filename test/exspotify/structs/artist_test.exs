defmodule Exspotify.Structs.ArtistTest do
  use ExUnit.Case
  alias Exspotify.Structs.{Artist, ExternalUrls, Followers, Image}

  describe "from_map/1" do
    test "creates Artist from complete API response" do
      artist_map = %{
        "id" => "artist123",
        "name" => "Test Artist",
        "type" => "artist",
        "uri" => "spotify:artist:artist123",
        "href" => "https://api.spotify.com/v1/artists/artist123",
        "popularity" => 85,
        "genres" => ["rock", "alternative", "indie"],
        "external_urls" => %{
          "spotify" => "https://open.spotify.com/artist/artist123"
        },
        "followers" => %{
          "href" => nil,
          "total" => 1500000
        },
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
        ]
      }

      result = Artist.from_map(artist_map)

      # Test required fields
      assert result.id == "artist123"
      assert result.name == "Test Artist"
      assert result.type == "artist"
      assert result.uri == "spotify:artist:artist123"

      # Test optional fields
      assert result.href == "https://api.spotify.com/v1/artists/artist123"
      assert result.popularity == 85
      assert result.genres == ["rock", "alternative", "indie"]

      # Test nested external_urls
      assert %ExternalUrls{} = result.external_urls
      assert result.external_urls.spotify == "https://open.spotify.com/artist/artist123"

      # Test nested followers
      assert %Followers{} = result.followers
      assert result.followers.total == 1500000
      assert result.followers.href == nil

      # Test nested images array
      assert is_list(result.images)
      assert length(result.images) == 2
      assert %Image{} = hd(result.images)
      assert hd(result.images).height == 640
    end

    test "creates Artist with minimal required fields" do
      artist_map = %{
        "id" => "minimal123",
        "name" => "Minimal Artist",
        "type" => "artist",
        "uri" => "spotify:artist:minimal123"
      }

      result = Artist.from_map(artist_map)

      assert result.id == "minimal123"
      assert result.name == "Minimal Artist"
      assert result.type == "artist"
      assert result.uri == "spotify:artist:minimal123"

      # Optional fields should be nil
      assert result.external_urls == nil
      assert result.followers == nil
      assert result.images == nil
      assert result.popularity == nil
    end

    test "validates required fields and raises error when missing" do
      incomplete_artist = %{
        "name" => "Missing ID Artist",
        "type" => "artist"
        # Missing "id" and "uri"
      }

      assert_raise ArgumentError, "Artist missing required fields: id, name, type, or uri", fn ->
        Artist.from_map(incomplete_artist)
      end
    end

    test "handles type validation for popularity field" do
      artist_map = %{
        "id" => "artist123",
        "name" => "Test Artist",
        "type" => "artist",
        "uri" => "spotify:artist:artist123",
        "popularity" => "not_a_number"  # String instead of integer
      }

      result = Artist.from_map(artist_map)

      # Popularity should be converted to nil due to type validation
      assert result.popularity == nil
    end

    test "handles malformed images gracefully" do
      artist_map = %{
        "id" => "artist123",
        "name" => "Test Artist",
        "type" => "artist",
        "uri" => "spotify:artist:artist123",
        "images" => "not_an_array"  # Invalid data type
      }

      result = Artist.from_map(artist_map)

      # Images should be set to nil when invalid input is provided
      assert result.images == nil
    end

    test "catches invalid image within images array" do
      artist_map = %{
        "id" => "artist123",
        "name" => "Test Artist",
        "type" => "artist",
        "uri" => "spotify:artist:artist123",
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

      # This should raise an error for the invalid Image
      assert_raise ArgumentError, "Image missing required URL field or URL is not a string", fn ->
        Artist.from_map(artist_map)
      end
    end

    test "handles empty arrays correctly" do
      artist_map = %{
        "id" => "artist123",
        "name" => "Test Artist",
        "type" => "artist",
        "uri" => "spotify:artist:artist123",
        "images" => [],
        "genres" => []
      }

      result = Artist.from_map(artist_map)

      assert result.images == []
      assert result.genres == []
    end

    test "handles nil nested objects gracefully" do
      artist_map = %{
        "id" => "artist123",
        "name" => "Test Artist",
        "type" => "artist",
        "uri" => "spotify:artist:artist123",
        "external_urls" => nil,
        "followers" => nil,
        "images" => nil
      }

      result = Artist.from_map(artist_map)

      assert result.external_urls == nil
      assert result.followers == nil
      assert result.images == nil
    end
  end
end
