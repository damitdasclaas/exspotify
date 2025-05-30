defmodule Exspotify.ErrorHandlingTest do
  use ExUnit.Case
  alias Exspotify.{Albums, Tracks, Error}

  describe "input validation" do
    test "validates empty album ID" do
      {:error, error} = Albums.get_album("", "valid_token")

      assert %Error{} = error
      assert error.type == :empty_id
      assert error.message == "album_id cannot be empty"
      assert error.details == %{field: "album_id"}
    end

    test "validates nil album ID" do
      {:error, error} = Albums.get_album(nil, "valid_token")

      assert %Error{} = error
      assert error.type == :empty_id
      assert error.message == "album_id cannot be nil"
      assert error.details == %{field: "album_id"}
    end

    test "validates invalid album ID type" do
      {:error, error} = Albums.get_album(123, "valid_token")

      assert %Error{} = error
      assert error.type == :invalid_id
      assert String.contains?(error.message, "album_id must be a non-empty string")
      assert error.details.field == "album_id"
      assert error.details.value == 123
    end

    test "validates empty token" do
      {:error, error} = Albums.get_album("valid_id", "")

      assert %Error{} = error
      assert error.type == :empty_token
      assert error.message == "Access token cannot be empty"
    end

    test "validates nil token" do
      {:error, error} = Albums.get_album("valid_id", nil)

      assert %Error{} = error
      assert error.type == :empty_token
      assert error.message == "Access token cannot be nil"
    end

    test "validates empty list of IDs" do
      {:error, error} = Albums.get_several_albums([], "valid_token")

      assert %Error{} = error
      assert error.type == :empty_list
      assert error.message == "album_ids cannot be empty"
      assert error.details == %{field: "album_ids"}
    end

    test "validates non-list album_ids" do
      {:error, error} = Albums.get_several_albums("not_a_list", "valid_token")

      assert %Error{} = error
      assert error.type == :invalid_type
      assert String.contains?(error.message, "album_ids must be a list")
    end

    test "validates individual IDs in list" do
      {:error, error} = Albums.get_several_albums(["valid_id", "", "another_valid"], "valid_token")

      assert %Error{} = error
      assert error.type == :invalid_id
      assert String.contains?(error.message, "album_ids[1] must be a non-empty string")
      assert error.details.field == "album_ids"
      assert error.details.index == 1
      assert error.details.value == ""
    end

    test "validates individual IDs with invalid types in list" do
      {:error, error} = Tracks.get_several_tracks(["valid_id", 123, "another_valid"], "valid_token")

      assert %Error{} = error
      assert error.type == :invalid_id
      assert String.contains?(error.message, "track_ids[1] must be a non-empty string")
      assert error.details.field == "track_ids"
      assert error.details.index == 1
      assert error.details.value == 123
    end
  end

  describe "Error module" do
    test "creates basic error" do
      error = Error.new(:test_error, "Test message")

      assert %Error{} = error
      assert error.type == :test_error
      assert error.message == "Test message"
      assert error.details == nil
      assert error.status == nil
    end

    test "creates error with details and status" do
      details = %{field: "test", value: "invalid"}
      error = Error.new(:validation_error, "Validation failed", details, 400)

      assert error.type == :validation_error
      assert error.message == "Validation failed"
      assert error.details == details
      assert error.status == 400
    end

    test "validates ID correctly" do
      assert :ok == Error.validate_id("valid_id", "test_field")
      assert {:error, %Error{type: :empty_id}} = Error.validate_id("", "test_field")
      assert {:error, %Error{type: :empty_id}} = Error.validate_id(nil, "test_field")
      assert {:error, %Error{type: :invalid_id}} = Error.validate_id(123, "test_field")
    end

    test "validates token correctly" do
      assert :ok == Error.validate_token("valid_token")
      assert {:error, %Error{type: :empty_token}} = Error.validate_token("")
      assert {:error, %Error{type: :empty_token}} = Error.validate_token(nil)
      assert {:error, %Error{type: :invalid_token}} = Error.validate_token(123)
    end

    test "validates list correctly" do
      assert :ok == Error.validate_list(["item1", "item2"], "test_field")
      assert {:error, %Error{type: :empty_list}} = Error.validate_list([], "test_field")
      assert {:error, %Error{type: :invalid_type}} = Error.validate_list("not_a_list", "test_field")
    end

    test "creates HTTP errors correctly" do
      error = Error.from_http_response(401, %{"error" => "invalid_token"})

      assert error.type == :unauthorized
      assert error.message == "Invalid or expired access token"
      assert error.status == 401
      assert error.details == %{response_body: %{"error" => "invalid_token"}}
    end

    test "creates rate limit error with retry-after" do
      body = %{"error" => "rate_limited", "retry_after" => 30}
      error = Error.from_http_response(429, body)

      assert error.type == :rate_limited
      assert error.message == "Rate limit exceeded. Retry after 30 seconds"
      assert error.status == 429
      assert error.details.retry_after == 30
    end

    test "creates network error" do
      reason = %{reason: :timeout}
      error = Error.network_error(reason)

      assert error.type == :network_error
      assert error.message == "Request timed out"
      assert error.details == %{reason: reason}
    end
  end
end
