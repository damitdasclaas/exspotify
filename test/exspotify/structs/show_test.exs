defmodule Exspotify.Structs.ShowTest do
  use ExUnit.Case
  alias Exspotify.Structs.{Show, ExternalUrls, Image}

  describe "from_map/1" do
    test "creates Show from complete API response" do
      show_map = %{
        "id" => "show123",
        "name" => "Awesome Podcast",
        "type" => "show",
        "uri" => "spotify:show:show123",
        "href" => "https://api.spotify.com/v1/shows/show123",
        "description" => "The best podcast ever",
        "html_description" => "<p>The best podcast ever</p>",
        "explicit" => false,
        "is_externally_hosted" => false,
        "languages" => ["en", "es"],
        "media_type" => "audio",
        "publisher" => "Awesome Media",
        "total_episodes" => 150,
        "available_markets" => ["US", "CA", "GB"],
        "external_urls" => %{
          "spotify" => "https://open.spotify.com/show/show123"
        },
        "images" => [
          %{
            "url" => "https://i.scdn.co/image/show_large.jpg",
            "height" => 640,
            "width" => 640
          },
          %{
            "url" => "https://i.scdn.co/image/show_medium.jpg",
            "height" => 300,
            "width" => 300
          }
        ],
        "copyrights" => [
          %{"text" => "© 2023 Awesome Media", "type" => "C"}
        ]
      }

      result = Show.from_map(show_map)

      # Test required fields
      assert result.id == "show123"
      assert result.name == "Awesome Podcast"
      assert result.type == "show"
      assert result.uri == "spotify:show:show123"

      # Test show-specific fields
      assert result.description == "The best podcast ever"
      assert result.publisher == "Awesome Media"
      assert result.total_episodes == 150
      assert result.languages == ["en", "es"]
      assert result.explicit == false

      # Test nested objects
      assert %ExternalUrls{} = result.external_urls
      assert result.external_urls.spotify == "https://open.spotify.com/show/show123"

      # Test images array
      assert is_list(result.images)
      assert length(result.images) == 2
      assert %Image{} = hd(result.images)
      assert hd(result.images).height == 640
    end

    test "creates Show with minimal required fields" do
      show_map = %{
        "id" => "minimal123",
        "name" => "Minimal Show",
        "type" => "show",
        "uri" => "spotify:show:minimal123"
      }

      result = Show.from_map(show_map)

      assert result.id == "minimal123"
      assert result.name == "Minimal Show"
      assert result.type == "show"
      assert result.uri == "spotify:show:minimal123"

      # Optional fields should be nil
      assert result.description == nil
      assert result.images == nil
      assert result.external_urls == nil
      assert result.total_episodes == nil
    end

    test "provides sensible defaults for missing required fields" do
      incomplete_show = %{
        "name" => "Incomplete Show"
        # Missing id, type, uri
      }

      result = Show.from_map(incomplete_show)

      assert result.id == "unknown"
      assert result.type == "show"
      assert result.uri == ""
      assert result.name == "Incomplete Show"
    end

    test "handles malformed images gracefully" do
      show_map = %{
        "id" => "show123",
        "name" => "Test Show",
        "type" => "show",
        "uri" => "spotify:show:show123",
        "images" => "not_an_array"
      }

      result = Show.from_map(show_map)

      # Should handle gracefully (defensive parsing now converts to nil)
      assert result.images == nil
    end

    test "handles type validation for total_episodes" do
      show_map = %{
        "id" => "show123",
        "name" => "Test Show",
        "type" => "show",
        "uri" => "spotify:show:show123",
        "total_episodes" => "not_a_number"
      }

      result = Show.from_map(show_map)

      # Should be passed through as-is (no validation yet)
      assert result.total_episodes == "not_a_number"
    end
  end
end
