defmodule Exspotify.Structs.DeviceTest do
  use ExUnit.Case
  alias Exspotify.Structs.Device

  describe "from_map/1" do
    test "creates Device from complete API response" do
      device_map = %{
        "id" => "device123",
        "name" => "MacBook Pro Speakers",
        "type" => "Computer",
        "is_active" => true,
        "is_private_session" => false,
        "is_restricted" => false,
        "volume_percent" => 65,
        "supports_volume" => true
      }

      result = Device.from_map(device_map)

      # Test required fields
      assert result.id == "device123"
      assert result.name == "MacBook Pro Speakers"
      assert result.type == "Computer"

      # Test device-specific fields
      assert result.is_active == true
      assert result.is_private_session == false
      assert result.volume_percent == 65
      assert result.supports_volume == true
    end

    test "creates Device with minimal required fields" do
      device_map = %{
        "id" => "minimal123",
        "name" => "Phone",
        "type" => "Smartphone"
      }

      result = Device.from_map(device_map)

      assert result.id == "minimal123"
      assert result.name == "Phone"
      assert result.type == "Smartphone"

      # Optional fields should be nil
      assert result.is_active == nil
      assert result.volume_percent == nil
      assert result.supports_volume == nil
    end

    test "provides sensible defaults for missing required fields" do
      incomplete_device = %{
        "name" => "Unknown Device"
        # Missing id, type
      }

      result = Device.from_map(incomplete_device)

      assert result.id == "unknown"
      assert result.type == "unknown"
      assert result.name == "Unknown Device"
    end

    test "handles invalid volume_percent gracefully" do
      device_map = %{
        "id" => "device123",
        "name" => "Test Device",
        "type" => "Computer",
        "volume_percent" => "not_a_number"
      }

      result = Device.from_map(device_map)

      # Should be passed through as-is (no validation yet)
      assert result.volume_percent == "not_a_number"
    end
  end
end
