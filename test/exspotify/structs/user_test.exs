defmodule Exspotify.Structs.UserTest do
  use ExUnit.Case
  alias Exspotify.Structs.{User, ExternalUrls, Followers, Image}

  describe "from_map/1" do
    test "creates User from complete API response" do
      user_map = %{
        "id" => "user123",
        "type" => "user",
        "uri" => "spotify:user:user123",
        "href" => "https://api.spotify.com/v1/users/user123",
        "display_name" => "Test User",
        "country" => "US",
        "email" => "test@example.com",
        "product" => "premium",
        "explicit_content" => %{
          "filter_enabled" => false,
          "filter_locked" => false
        },
        "external_urls" => %{
          "spotify" => "https://open.spotify.com/user/user123"
        },
        "followers" => %{
          "href" => nil,
          "total" => 42
        },
        "images" => [
          %{
            "url" => "https://i.scdn.co/image/user_profile.jpg",
            "height" => 300,
            "width" => 300
          }
        ]
      }

      result = User.from_map(user_map)

      # Test required fields
      assert result.id == "user123"
      assert result.type == "user"
      assert result.uri == "spotify:user:user123"

      # Test optional fields
      assert result.href == "https://api.spotify.com/v1/users/user123"
      assert result.display_name == "Test User"
      assert result.country == "US"
      assert result.email == "test@example.com"
      assert result.product == "premium"

      # Test nested explicit_content (kept as map)
      assert is_map(result.explicit_content)
      assert result.explicit_content["filter_enabled"] == false

      # Test nested external_urls
      assert %ExternalUrls{} = result.external_urls
      assert result.external_urls.spotify == "https://open.spotify.com/user/user123"

      # Test nested followers
      assert %Followers{} = result.followers
      assert result.followers.total == 42
      assert result.followers.href == nil

      # Test nested images array
      assert is_list(result.images)
      assert length(result.images) == 1
      assert %Image{} = hd(result.images)
      assert hd(result.images).url == "https://i.scdn.co/image/user_profile.jpg"
    end

    test "creates User with minimal required fields" do
      user_map = %{
        "id" => "minimal123",
        "type" => "user",
        "uri" => "spotify:user:minimal123"
      }

      result = User.from_map(user_map)

      assert result.id == "minimal123"
      assert result.type == "user"
      assert result.uri == "spotify:user:minimal123"

      # Optional fields should be nil
      assert result.display_name == nil
      assert result.country == nil
      assert result.email == nil
      assert result.external_urls == nil
      assert result.followers == nil
      assert result.images == nil
    end

    test "handles malformed images gracefully" do
      user_map = %{
        "id" => "user123",
        "type" => "user",
        "uri" => "spotify:user:user123",
        "images" => "not_an_array"  # Invalid data type
      }

      result = User.from_map(user_map)

      # Should now handle gracefully by setting images to nil
      assert result.images == nil
    end

    test "handles empty arrays correctly" do
      user_map = %{
        "id" => "user123",
        "type" => "user",
        "uri" => "spotify:user:user123",
        "images" => []
      }

      result = User.from_map(user_map)

      assert result.images == []
    end

    test "handles nil nested objects gracefully" do
      user_map = %{
        "id" => "user123",
        "type" => "user",
        "uri" => "spotify:user:user123",
        "external_urls" => nil,
        "followers" => nil,
        "images" => nil,
        "explicit_content" => nil
      }

      result = User.from_map(user_map)

      assert result.external_urls == nil
      assert result.followers == nil
      assert result.images == nil
      assert result.explicit_content == nil
    end

    test "reveals current validation gaps" do
      # This test documents what happens with invalid data types for non-required fields
      invalid_user = %{
        "id" => "user456",  # Valid required field
        "type" => "user",  # Valid required field
        "uri" => "spotify:user:user456",  # Valid required field
        "country" => 123,  # Number instead of string
        "email" => false  # Boolean instead of string
      }

      result = User.from_map(invalid_user)

      # Documents current behavior - no type validation for string fields
      assert result.country == 123
      assert result.email == false

      # This shows we need better validation for string fields
      refute is_binary(result.country)
      refute is_binary(result.email)
    end

    test "handles public user profile (limited fields)" do
      # Public profiles have limited information
      public_user_map = %{
        "id" => "public123",
        "type" => "user",
        "uri" => "spotify:user:public123",
        "display_name" => "Public User",
        "external_urls" => %{
          "spotify" => "https://open.spotify.com/user/public123"
        },
        "followers" => %{
          "href" => nil,
          "total" => 100
        }
        # No email, country, explicit_content (private fields)
      }

      result = User.from_map(public_user_map)

      assert result.id == "public123"
      assert result.display_name == "Public User"
      assert result.followers.total == 100

      # Private fields should be nil
      assert result.email == nil
      assert result.country == nil
      assert result.explicit_content == nil
    end

    test "provides sensible defaults for missing required fields" do
      incomplete_user = %{
        "display_name" => "Missing Fields User",
        "type" => "user"
        # Missing "id" and "uri"
      }

      result = User.from_map(incomplete_user)

      # Now provides sensible defaults instead of raising errors
      assert result.id == "unknown"
      assert result.uri == ""
      assert result.display_name == "Missing Fields User"
      assert result.type == "user"
    end
  end
end
