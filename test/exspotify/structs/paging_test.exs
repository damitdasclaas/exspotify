defmodule Exspotify.Structs.PagingTest do
  use ExUnit.Case
  alias Exspotify.Structs.{Paging, Track, Artist}

  describe "from_map/2" do
    test "creates Paging with raw items (no parser)" do
      paging_map = %{
        "href" => "https://api.spotify.com/v1/tracks?offset=0&limit=20",
        "limit" => 20,
        "next" => "https://api.spotify.com/v1/tracks?offset=20&limit=20",
        "offset" => 0,
        "previous" => nil,
        "total" => 100,
        "items" => [
          %{"id" => "item1", "name" => "Item 1"},
          %{"id" => "item2", "name" => "Item 2"}
        ]
      }

      result = Paging.from_map(paging_map)

      assert result.href == "https://api.spotify.com/v1/tracks?offset=0&limit=20"
      assert result.limit == 20
      assert result.next == "https://api.spotify.com/v1/tracks?offset=20&limit=20"
      assert result.offset == 0
      assert result.previous == nil
      assert result.total == 100
      assert length(result.items) == 2
      assert hd(result.items) == %{"id" => "item1", "name" => "Item 1"}
    end

    test "creates Paging with Track parser" do
      paging_map = %{
        "limit" => 5,
        "offset" => 0,
        "total" => 50,
        "items" => [
          %{
            "id" => "track1",
            "name" => "Track One",
            "type" => "track",
            "uri" => "spotify:track:track1"
          },
          %{
            "id" => "track2",
            "name" => "Track Two",
            "type" => "track",
            "uri" => "spotify:track:track2"
          }
        ]
      }

      result = Paging.from_map(paging_map, &Track.from_map/1)

      assert result.limit == 5
      assert result.total == 50
      assert length(result.items) == 2

      # Check items were parsed as Track structs
      assert %Track{} = hd(result.items)
      assert hd(result.items).id == "track1"
      assert hd(result.items).name == "Track One"
    end

    test "creates Paging with Artist parser" do
      paging_map = %{
        "limit" => 10,
        "offset" => 20,
        "total" => 500,
        "items" => [
          %{
            "id" => "artist1",
            "name" => "Artist One",
            "type" => "artist",
            "uri" => "spotify:artist:artist1"
          }
        ]
      }

      result = Paging.from_map(paging_map, &Artist.from_map/1)

      assert result.limit == 10
      assert result.offset == 20
      assert result.total == 500
      assert length(result.items) == 1

      # Check item was parsed as Artist struct
      assert %Artist{} = hd(result.items)
      assert hd(result.items).id == "artist1"
      assert hd(result.items).name == "Artist One"
    end

    test "handles empty items array" do
      paging_map = %{
        "limit" => 20,
        "offset" => 0,
        "total" => 0,
        "items" => []
      }

      result = Paging.from_map(paging_map, &Track.from_map/1)

      assert result.limit == 20
      assert result.offset == 0
      assert result.total == 0
      assert result.items == []
    end

    test "handles nil items array" do
      paging_map = %{
        "limit" => 20,
        "offset" => 0,
        "total" => 0,
        "items" => nil
      }

      result = Paging.from_map(paging_map)

      assert result.items == []
    end

    test "handles last page (no next)" do
      paging_map = %{
        "href" => "https://api.spotify.com/v1/tracks?offset=80&limit=20",
        "limit" => 20,
        "next" => nil,
        "offset" => 80,
        "previous" => "https://api.spotify.com/v1/tracks?offset=60&limit=20",
        "total" => 85,
        "items" => [
          %{"id" => "last1"},
          %{"id" => "last2"}
        ]
      }

      result = Paging.from_map(paging_map)

      assert result.next == nil
      assert result.previous == "https://api.spotify.com/v1/tracks?offset=60&limit=20"
      assert result.offset == 80
      assert result.total == 85
      assert length(result.items) == 2
    end

    test "creates Paging with custom parser function" do
      # Custom parser that extracts just the name
      name_parser = fn item -> item["name"] end

      paging_map = %{
        "limit" => 3,
        "offset" => 0,
        "total" => 10,
        "items" => [
          %{"id" => "1", "name" => "First"},
          %{"id" => "2", "name" => "Second"},
          %{"id" => "3", "name" => "Third"}
        ]
      }

      result = Paging.from_map(paging_map, name_parser)

      assert result.items == ["First", "Second", "Third"]
    end
  end
end
