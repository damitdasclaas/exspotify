defmodule Exspotify.Structs.ExternalUrlsTest do
  use ExUnit.Case
  alias Exspotify.Structs.ExternalUrls

  describe "from_map/1" do
    test "creates ExternalUrls from valid spotify URL" do
      urls_map = %{
        "spotify" => "https://open.spotify.com/track/123"
      }

      result = ExternalUrls.from_map(urls_map)

      assert result.spotify == "https://open.spotify.com/track/123"
    end

    test "handles missing spotify URL gracefully" do
      empty_map = %{}

      result = ExternalUrls.from_map(empty_map)

      assert result.spotify == nil
    end

    test "handles nil values correctly" do
      urls_map = %{
        "spotify" => nil
      }

      result = ExternalUrls.from_map(urls_map)

      assert result.spotify == nil
    end

    test "ignores unknown URL types" do
      # Tests that unknown keys are ignored (expected behavior)
      urls_map = %{
        "spotify" => "https://open.spotify.com/track/123",
        "apple_music" => "https://music.apple.com/track/123",  # Not in struct
        "youtube" => "https://youtube.com/watch?v=123"  # Not in struct
      }

      result = ExternalUrls.from_map(urls_map)

      assert result.spotify == "https://open.spotify.com/track/123"
      # Other URLs should be ignored since they're not in the struct
    end
  end
end
