defmodule Exspotify.Structs.ImageTest do
  use ExUnit.Case
  alias Exspotify.Structs.Image

  describe "from_map/1" do
    test "creates Image from valid map with all fields" do
      image_map = %{
        "url" => "https://i.scdn.co/image/ab67616d0000b273abcd1234",
        "height" => 640,
        "width" => 640
      }

      result = Image.from_map(image_map)

      assert result.url == "https://i.scdn.co/image/ab67616d0000b273abcd1234"
      assert result.height == 640
      assert result.width == 640
    end

    test "creates Image with only required url field" do
      image_map = %{
        "url" => "https://i.scdn.co/image/ab67616d0000b273minimal"
      }

      result = Image.from_map(image_map)

      assert result.url == "https://i.scdn.co/image/ab67616d0000b273minimal"
      assert result.height == nil
      assert result.width == nil
    end

    test "handles missing optional fields gracefully" do
      image_map = %{
        "url" => "https://example.com/image.jpg",
        "height" => 300
        # width is missing
      }

      result = Image.from_map(image_map)

      assert result.url == "https://example.com/image.jpg"
      assert result.height == 300
      assert result.width == nil
    end

    test "handles nil values for optional fields" do
      image_map = %{
        "url" => "https://example.com/image.jpg",
        "height" => nil,
        "width" => nil
      }

      result = Image.from_map(image_map)

      assert result.url == "https://example.com/image.jpg"
      assert result.height == nil
      assert result.width == nil
    end
  end
end
