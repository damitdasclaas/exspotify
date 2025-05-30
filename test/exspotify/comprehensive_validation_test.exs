defmodule Exspotify.ComprehensiveValidationTest do
  use ExUnit.Case
  alias Exspotify.{Albums, Artists, Users, Playlists, Tracks, Error}

  describe "User input validation returns errors (NOT defaults)" do
    test "empty IDs return errors across all modules" do
      # Albums
      assert {:error, %Error{type: :empty_id}} = Albums.get_album("", "token")
      assert {:error, %Error{type: :empty_id}} = Albums.get_album_tracks("", "token")

      # Artists
      assert {:error, %Error{type: :empty_id}} = Artists.get_artist("", "token")
      assert {:error, %Error{type: :empty_id}} = Artists.get_artist_albums("", "token")

      # Users
      assert {:error, %Error{type: :empty_id}} = Users.get_user_profile("", "token")

      # Playlists
      assert {:error, %Error{type: :empty_id}} = Playlists.get_playlist("", "token")
      assert {:error, %Error{type: :empty_id}} = Playlists.get_playlist_items("", "token")

      # Tracks
      assert {:error, %Error{type: :empty_id}} = Tracks.get_track("", "token")
    end

    test "nil tokens return errors across all modules" do
      # Albums
      assert {:error, %Error{type: :empty_token}} = Albums.get_album("id", nil)

      # Artists
      assert {:error, %Error{type: :empty_token}} = Artists.get_artist("id", nil)

      # Users
      assert {:error, %Error{type: :empty_token}} = Users.get_current_user_profile(nil)

      # Playlists
      assert {:error, %Error{type: :empty_token}} = Playlists.get_playlist("id", nil)

      # Tracks
      assert {:error, %Error{type: :empty_token}} = Tracks.get_track("id", nil)
    end

    test "invalid list types return errors" do
      # Albums
      assert {:error, %Error{type: :invalid_type}} = Albums.get_several_albums("not_a_list", "token")

      # Artists
      assert {:error, %Error{type: :invalid_type}} = Artists.get_several_artists("not_a_list", "token")

      # Tracks
      assert {:error, %Error{type: :invalid_type}} = Tracks.get_several_tracks("not_a_list", "token")

      # Users
      assert {:error, %Error{type: :invalid_type}} = Users.follow_artists_or_users("artist", "token", "not_a_list")

      # Playlists
      assert {:error, %Error{type: :invalid_type}} = Playlists.check_if_user_follows_playlist("id", "token", "not_a_list")
    end

    test "empty lists return errors" do
      # Albums
      assert {:error, %Error{type: :empty_list}} = Albums.get_several_albums([], "token")

      # Artists
      assert {:error, %Error{type: :empty_list}} = Artists.get_several_artists([], "token")

      # Tracks
      assert {:error, %Error{type: :empty_list}} = Tracks.get_several_tracks([], "token")
    end

    test "invalid IDs within lists return specific index errors" do
      # Albums
      {:error, error} = Albums.get_several_albums(["valid", "", "also_valid"], "token")
      assert error.type == :invalid_id
      assert String.contains?(error.message, "[1]")  # Points to index 1 (empty string)
      assert error.details.index == 1

      # Artists
      {:error, error} = Artists.get_several_artists(["valid", 123, "also_valid"], "token")
      assert error.type == :invalid_id
      assert String.contains?(error.message, "[1]")  # Points to index 1 (number)
      assert error.details.index == 1

      # Tracks
      {:error, error} = Tracks.get_several_tracks(["valid", nil, "also_valid"], "token")
      assert error.type == :invalid_id
      assert String.contains?(error.message, "[1]")  # Points to index 1 (nil)
      assert error.details.index == 1
    end

    test "invalid enum values return errors with helpful context" do
      # Users - invalid top items type
      {:error, error} = Users.get_user_top_items("invalid_type", "token")
      assert error.type == :invalid_type
      assert String.contains?(error.message, "must be 'artists' or 'tracks'")
      assert error.details.valid_types == ["artists", "tracks"]

      # Users - invalid follow type
      {:error, error} = Users.follow_artists_or_users("invalid_type", "token", ["id"])
      assert error.type == :invalid_type
      assert String.contains?(error.message, "must be 'artist' or 'user'")
      assert error.details.valid_types == ["artist", "user"]
    end

    test "playlist-specific validation returns errors" do
      # Empty playlist name
      {:error, error} = Playlists.create_playlist("user_id", "", "token")
      assert error.type == :invalid_id
      assert String.contains?(error.message, "Playlist name must be a non-empty string")

      # Empty image data
      {:error, error} = Playlists.add_custom_playlist_cover_image("playlist_id", "", "token")
      assert error.type == :invalid_id
      assert String.contains?(error.message, "Image data must be a non-empty string")
    end
  end

  describe "API response parsing uses defaults (NOT errors)" do
    test "Album.from_map handles missing data gracefully" do
      incomplete_response = %{
        "name" => "Some Album"
        # Missing: id, type, uri, release_date, artists, etc.
      }

      result = Exspotify.Structs.Album.from_map(incomplete_response)

      # Uses defaults for missing required fields
      assert result.id == "unknown"
      assert result.type == "album"
      assert result.uri == ""
      assert result.name == "Some Album"  # From API

      # Missing optional fields become nil (acceptable)
      assert result.release_date == nil
      assert result.artists == nil
      assert result.popularity == nil
    end

    test "Artist.from_map handles missing data gracefully" do
      incomplete_response = %{
        "name" => "Some Artist"
        # Missing: id, type, uri, images, etc.
      }

      result = Exspotify.Structs.Artist.from_map(incomplete_response)

      # Uses defaults for missing required fields
      assert result.id == "unknown"
      assert result.type == "artist"
      assert result.uri == ""
      assert result.name == "Some Artist"  # From API

      # Missing optional fields become nil (acceptable)
      assert result.images == nil
      assert result.popularity == nil
    end

    test "handles completely empty API responses with all defaults" do
      empty_response = %{}

      album = Exspotify.Structs.Album.from_map(empty_response)
      assert album.id == "unknown"
      assert album.name == "Untitled Album"
      assert album.type == "album"
      assert album.uri == ""

      artist = Exspotify.Structs.Artist.from_map(empty_response)
      assert artist.id == "unknown"
      assert artist.name == "Unknown Artist"
      assert artist.type == "artist"
      assert artist.uri == ""
    end

    test "demonstrates the separation: input validation vs response parsing" do
      # User input validation → Returns errors
      assert {:error, %Error{type: :empty_id}} = Albums.get_album("", "token")

      # API response parsing → Uses defaults
      empty_response = %{}
      album = Exspotify.Structs.Album.from_map(empty_response)
      assert album.id == "unknown"
      assert album.name == "Untitled Album"
    end
  end

  describe "Validation vs Parsing separation" do
    test "demonstrates the correct flow: validate input first, then parse response" do
      # Step 1: User input validation catches bad input BEFORE HTTP request
      # This prevents wasted API calls and provides immediate feedback

      # BAD: Empty ID gets caught immediately
      assert {:error, %Error{type: :empty_id}} = Albums.get_album("", "token")
      # No HTTP request was made, no default returned

      # BAD: Invalid token gets caught immediately
      assert {:error, %Error{type: :empty_token}} = Albums.get_album("id", nil)
      # No HTTP request was made, no default returned

      # GOOD: Valid input would proceed to HTTP request
      # (We can't test HTTP without a real token, but the flow would be:)
      # 1. Validation passes ✓
      # 2. HTTP request made
      # 3. Response parsing uses defaults for missing Spotify data
      # 4. Returns {:ok, %Album{}} with appropriate defaults/nil values
    end

    test "struct parsing is defensive but doesn't mask user errors" do
      # This is what happens AFTER a successful HTTP response from Spotify
      # Missing/malformed data from Spotify API gets defaults
      spotify_response = %{
        "name" => "Album from Spotify",
        "artists" => [
          %{"name" => "Artist with missing ID"}  # Missing required fields
        ]
      }

      album = Exspotify.Structs.Album.from_map(spotify_response)

      # Album uses defaults for missing fields
      assert album.id == "unknown"
      assert album.name == "Album from Spotify"

      # Nested artist also uses defaults
      artist = hd(album.artists)
      assert artist.id == "unknown"
      assert artist.name == "Artist with missing ID"
      assert artist.type == "artist"  # Default
      assert artist.uri == ""  # Default

      # This is DIFFERENT from user input validation which returns errors
      # User provides bad input → {:error, %Error{}}
      # Spotify provides incomplete data → Use defaults in structs
    end
  end
end
