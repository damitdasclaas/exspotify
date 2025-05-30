defmodule Exspotify.Structs.QueueTest do
  use ExUnit.Case
  alias Exspotify.Structs.{Queue, Track, Episode}

  describe "from_map/1" do
    test "creates Queue with track items" do
      queue_map = %{
        "currently_playing" => %{
          "id" => "current123",
          "name" => "Currently Playing Track",
          "type" => "track",
          "uri" => "spotify:track:current123"
        },
        "queue" => [
          %{
            "id" => "next123",
            "name" => "Next Track",
            "type" => "track",
            "uri" => "spotify:track:next123"
          },
          %{
            "id" => "after123",
            "name" => "After That Track",
            "type" => "track",
            "uri" => "spotify:track:after123"
          }
        ]
      }

      result = Queue.from_map(queue_map)

      # Test currently playing
      assert %Track{} = result.currently_playing
      assert result.currently_playing.name == "Currently Playing Track"

      # Test queue array
      assert is_list(result.queue)
      assert length(result.queue) == 2
      assert %Track{} = hd(result.queue)
      assert hd(result.queue).name == "Next Track"
    end

    test "creates Queue with episode items" do
      queue_map = %{
        "currently_playing" => %{
          "id" => "episode123",
          "name" => "Current Episode",
          "type" => "episode",
          "uri" => "spotify:episode:episode123"
        },
        "queue" => [
          %{
            "id" => "next_episode123",
            "name" => "Next Episode",
            "type" => "episode",
            "uri" => "spotify:episode:next_episode123"
          }
        ]
      }

      result = Queue.from_map(queue_map)

      # Test currently playing episode
      assert %Episode{} = result.currently_playing
      assert result.currently_playing.name == "Current Episode"

      # Test queue with episode
      assert [%Episode{}] = result.queue
      assert hd(result.queue).name == "Next Episode"
    end

    test "handles empty queue" do
      queue_map = %{
        "currently_playing" => nil,
        "queue" => []
      }

      result = Queue.from_map(queue_map)

      assert result.currently_playing == nil
      assert result.queue == []
    end

    test "handles mixed track and episode queue" do
      queue_map = %{
        "currently_playing" => %{
          "id" => "track123",
          "name" => "Track Playing",
          "type" => "track",
          "uri" => "spotify:track:track123"
        },
        "queue" => [
          %{
            "id" => "episode123",
            "name" => "Episode Next",
            "type" => "episode",
            "uri" => "spotify:episode:episode123"
          },
          %{
            "id" => "track456",
            "name" => "Track After",
            "type" => "track",
            "uri" => "spotify:track:track456"
          }
        ]
      }

      result = Queue.from_map(queue_map)

      assert %Track{} = result.currently_playing
      assert length(result.queue) == 2
      assert %Episode{} = Enum.at(result.queue, 0)
      assert %Track{} = Enum.at(result.queue, 1)
    end
  end
end
