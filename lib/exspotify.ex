defmodule Exspotify do
  @moduledoc """
  A comprehensive Elixir client for the Spotify Web API.

  Exspotify provides complete coverage of the Spotify Web API with type-safe struct parsing,
  automatic token management, and professional error handling. Perfect for building music
  applications, analytics tools, or integrating Spotify functionality into your Elixir projects.

  ## Features

  - **🎵 Comprehensive API Coverage** - 13+ modules covering Albums, Artists, Tracks, Playlists, Search, Player, Shows, Episodes, Audiobooks, and more
  - **🏗️ Type-Safe Structs** - All API responses parsed into well-defined Elixir structs with proper types
  - **🔐 Automatic Token Management** - Built-in token handling with automatic refresh support for both client credentials and user authorization flows

  ## Quick Start

  ### 1. Configuration

  Add your Spotify app credentials to `config/config.exs`:

      config :exspotify,
        client_id: "your_spotify_client_id",
        client_secret: "your_spotify_client_secret",
        redirect_uri: "http://localhost:4000/auth/callback"

  ### 2. Get an Access Token

      # For app-only access (no user permissions needed)
      {:ok, token} = Exspotify.TokenManager.get_token()

      # For user access (requires authorization flow)
      scopes = ["user-read-private", "playlist-read-private"]
      {:ok, auth_url} = Exspotify.Auth.build_authorization_url(scopes)
      # Redirect user to auth_url, get code back, then:
      {:ok, %{"access_token" => user_token}} = Exspotify.Auth.exchange_code_for_token(code)

  ### 3. Use the API

      # Get album information
      {:ok, album} = Exspotify.Albums.get_album("4aawyAB9vmqN3uQ7FjRGTy", token)
      IO.puts(album.name)  # "Global Warming"

      # Search for tracks
      {:ok, results} = Exspotify.Search.search("Bohemian Rhapsody", "track", token)
      track = List.first(results["tracks"].items)
      IO.puts("\#{track.name} by \#{List.first(track.artists).name}")

      # Get user's playlists (requires user token)
      {:ok, playlists} = Exspotify.Playlists.get_current_users_playlists(user_token)

  ## API Modules

  ### Core Content
  - `Exspotify.Albums` - Album information and user's saved albums
  - `Exspotify.Artists` - Artist information, albums, and top tracks
  - `Exspotify.Tracks` - Track information and user's saved tracks
  - `Exspotify.Playlists` - Complete playlist management
  - `Exspotify.Search` - Search across all content types

  ### User & Playback
  - `Exspotify.Users` - User profiles and social features
  - `Exspotify.Player` - Playback control and state management

  ### Additional Content
  - `Exspotify.Shows` - Podcast show management
  - `Exspotify.Episodes` - Podcast episode management
  - `Exspotify.Audiobooks` - Audiobook management
  - `Exspotify.Chapters` - Audiobook chapter management
  - `Exspotify.Categories` - Browse categories
  - `Exspotify.Markets` - Available markets

  ### Core Infrastructure
  - `Exspotify.Auth` - Authentication flow management
  - `Exspotify.TokenManager` - Automatic token management
  - `Exspotify.Error` - Structured error handling
  - `Exspotify.Client` - HTTP client with debug logging

  ## Common Patterns

  ### Error Handling

  All functions return `{:ok, result}` or `{:error, %Exspotify.Error{}}`:

      case Exspotify.Albums.get_album("invalid_id", token) do
        {:ok, album} ->
          IO.puts("Album: \#{album.name}")
        {:error, %Exspotify.Error{type: :not_found, suggestion: suggestion}} ->
          IO.puts("Error: \#{suggestion}")
      end

  ### Working with Paginated Results

  Many endpoints return paginated results using `Exspotify.Structs.Paging`:

      {:ok, albums} = Exspotify.Albums.get_users_saved_albums(token, limit: 50)

      # Access items
      Enum.each(albums.items, fn saved_album ->
        IO.puts("\#{saved_album["album"].name} - saved at \#{saved_album["added_at"]}")
      end)

      # Check for more pages
      if albums.next do
        IO.puts("More albums available...")
      end

  ### Working with Type-Safe Structs

  All responses are parsed into typed structs:

      {:ok, album} = Exspotify.Albums.get_album("123", token)

      album.id          # String.t() - "123"
      album.name        # String.t() - "Album Name"
      album.artists     # [%Exspotify.Structs.Artist{}]
      album.images      # [%Exspotify.Structs.Image{}]
      album.release_date # String.t() | nil - "2023-01-01"

  ## Debug Logging

  Enable debug logging to see all API requests:

      # In config/dev.exs
      config :exspotify, debug: true

  This will output:

      [debug] Exspotify API Request: GET https://api.spotify.com/v1/albums/123
      [debug] Exspotify API Response: 200 - Success

  ## Configuration

  All available configuration options:

      config :exspotify,
        client_id: "your_client_id",           # Required for all flows
        client_secret: "your_client_secret",   # Required for all flows
        redirect_uri: "http://localhost:4000", # Required for user auth flows
        base_url: "https://api.spotify.com/v1", # Optional, defaults to Spotify API
        debug: false                           # Optional, enables request logging

  ## Examples

  See the README.md for comprehensive examples including playlist creation,
  playback control, and user management workflows.
  """

  @doc """
  Returns the current version of Exspotify.
  """
  @spec version() :: String.t()
  def version do
    Application.spec(:exspotify, :vsn) |> to_string()
  end
end
