defmodule Exspotify.Structs.EpisodeTest do
  use ExUnit.Case
  alias Exspotify.Structs.{Episode, ExternalUrls, Image, ResumePoint, Show}

  describe "from_map/1" do
    test "creates Episode from complete API response" do
      episode_map = %{
        "id" => "episode123",
        "name" => "Great Episode",
        "type" => "episode",
        "uri" => "spotify:episode:episode123",
        "href" => "https://api.spotify.com/v1/episodes/episode123",
        "description" => "An amazing podcast episode",
        "duration_ms" => 1800000,
        "explicit" => false,
        "release_date" => "2023-10-15",
        "language" => "en",
        "languages" => ["en"],
        "is_externally_hosted" => false,
        "is_playable" => true,
        "audio_preview_url" => "https://audio.preview.url",
        "external_urls" => %{
          "spotify" => "https://open.spotify.com/episode/episode123"
        },
        "images" => [
          %{
            "url" => "https://i.scdn.co/image/episode.jpg",
            "height" => 640,
            "width" => 640
          }
        ],
        "resume_point" => %{
          "fully_played" => false,
          "resume_position_ms" => 300000
        },
        "show" => %{
          "id" => "show123",
          "name" => "Awesome Podcast",
          "type" => "show",
          "uri" => "spotify:show:show123"
        }
      }

      result = Episode.from_map(episode_map)

      # Test required fields
      assert result.id == "episode123"
      assert result.name == "Great Episode"
      assert result.type == "episode"
      assert result.uri == "spotify:episode:episode123"

      # Test episode-specific fields
      assert result.description == "An amazing podcast episode"
      assert result.duration_ms == 1800000
      assert result.explicit == false
      assert result.language == "en"
      assert result.is_playable == true

      # Test nested objects
      assert %ExternalUrls{} = result.external_urls
      assert %ResumePoint{} = result.resume_point
      assert result.resume_point.resume_position_ms == 300000
      assert %Show{} = result.show
      assert result.show.name == "Awesome Podcast"

      # Test images array
      assert is_list(result.images)
      assert length(result.images) == 1
      assert %Image{} = hd(result.images)
    end

    test "creates Episode with minimal required fields" do
      episode_map = %{
        "id" => "minimal123",
        "name" => "Minimal Episode",
        "type" => "episode",
        "uri" => "spotify:episode:minimal123"
      }

      result = Episode.from_map(episode_map)

      assert result.id == "minimal123"
      assert result.name == "Minimal Episode"
      assert result.type == "episode"
      assert result.uri == "spotify:episode:minimal123"

      # Optional fields should be nil
      assert result.show == nil
      assert result.resume_point == nil
      assert result.images == nil
    end

    test "provides sensible defaults for missing required fields" do
      incomplete_episode = %{
        "name" => "Incomplete Episode"
        # Missing id, type, uri
      }

      result = Episode.from_map(incomplete_episode)

      assert result.id == "unknown"
      assert result.type == "episode"
      assert result.uri == ""
      assert result.name == "Incomplete Episode"
    end

    test "handles malformed nested objects gracefully" do
      episode_map = %{
        "id" => "episode123",
        "name" => "Test Episode",
        "type" => "episode",
        "uri" => "spotify:episode:episode123",
        "images" => "not_an_array",
        "show" => "not_an_object"
      }

      result = Episode.from_map(episode_map)

      # Should handle gracefully with defensive parsing
      assert result.images == nil  # Invalid images converted to nil
      assert result.show == nil    # Invalid show converted to nil
    end

    test "handles type validation for duration field" do
      episode_map = %{
        "id" => "episode123",
        "name" => "Test Episode",
        "type" => "episode",
        "uri" => "spotify:episode:episode123",
        "duration_ms" => "not_a_number"
      }

      result = Episode.from_map(episode_map)

      # Duration should be passed through as-is (no validation yet)
      assert result.duration_ms == "not_a_number"
    end

    test "handles complex show nesting" do
      episode_map = %{
        "id" => "episode123",
        "name" => "Test Episode",
        "type" => "episode",
        "uri" => "spotify:episode:episode123",
        "show" => %{
          "id" => "show123",
          "name" => "Test Show",
          "type" => "show",
          "uri" => "spotify:show:show123",
          "images" => [
            %{"url" => "https://show.image.jpg", "height" => 300}
          ]
        }
      }

      result = Episode.from_map(episode_map)

      assert %Show{} = result.show
      assert result.show.id == "show123"
      assert result.show.name == "Test Show"
      # Show should have its own image parsing
      assert is_list(result.show.images)
    end
  end
end
