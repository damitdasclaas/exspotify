# Exspotify

A comprehensive Elixir client for the Spotify Web API with complete coverage of endpoints, type-safe struct parsing, and automatic token management.

[![Hex.pm](https://img.shields.io/hexpm/v/exspotify.svg)](https://hex.pm/packages/exspotify)
[![Documentation](https://img.shields.io/badge/documentation-hexdocs-blue.svg)](https://hexdocs.pm/exspotify)

## Features

- **🎵 Comprehensive API Coverage** - 13+ modules covering Albums, Artists, Tracks, Playlists, Search, Player, Shows, Episodes, Audiobooks, and more
- **🏗️ Type-Safe Structs** - All API responses parsed into well-defined Elixir structs with proper types
- **🔐 Automatic Token Management** - Built-in token handling with automatic refresh support for both client credentials and user authorization flows

## Installation

Add `exspotify` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:exspotify, "~> 0.1.3"}
  ]
end
```

## Quick Start

### 1. Configuration

Add your Spotify app credentials to `config/config.exs`:

```elixir
config :exspotify,
  client_id: "your_spotify_client_id",
  client_secret: "your_spotify_client_secret",
  redirect_uri: "http://localhost:4000/auth/callback"  # For user auth flows
```

**When using only user auth (e.g. in a Phoenix app with OAuth):** set `token_manager: false` so the client-credentials TokenManager is not started:

```elixir
config :exspotify,
  client_id: "...",
  client_secret: "...",
  redirect_uri: "http://localhost:4000/auth/callback",
  token_manager: false
```

### 2. Basic Usage

```elixir
# Get an access token
{:ok, token} = Exspotify.TokenManager.get_token()

# Get album information
{:ok, album} = Exspotify.Albums.get_album("4aawyAB9vmqN3uQ7FjRGTy", token)
IO.puts(album.name)  # "Global Warming"

# Search for tracks
{:ok, results} = Exspotify.Search.search("Bohemian Rhapsody", "track", token)
track = List.first(results["tracks"].items)
IO.puts("#{track.name} by #{List.first(track.artists).name}")

# Get user's playlists (requires user authorization)
{:ok, playlists} = Exspotify.Playlists.get_current_users_playlists(user_token)
```

## Authentication

Exspotify supports both authentication flows:

### Client Credentials Flow (App-only access)

```elixir
# Automatic token management
{:ok, token} = Exspotify.TokenManager.get_token()

# Manual token management
{:ok, %{"access_token" => token}} = Exspotify.Auth.get_access_token()
```

### Authorization Code Flow (User access)

```elixir
# 1. Build authorization URL (use built-in scopes for playlists + playback)
scopes = Exspotify.Auth.scopes_for_user_playback()  # playlist-read-private, streaming, etc.
{:ok, auth_url} = Exspotify.Auth.build_authorization_url(scopes, "state123")
# Redirect user to URI.to_string(auth_url)

# 2. Redirect user to auth_url, they'll return with a code

# 3. Exchange code for tokens
{:ok, %{"access_token" => token, "refresh_token" => refresh}} = 
  Exspotify.Auth.exchange_code_for_token(code)

# 4. Refresh when needed
{:ok, %{"access_token" => new_token}} = 
  Exspotify.Auth.refresh_access_token(refresh)
```

## API Coverage

| Module | Endpoints | Description |
|--------|-----------|-------------|
| `Albums` | 8 endpoints | Get albums, user's saved albums, new releases |
| `Artists` | 3 endpoints | Get artists, artist albums, top tracks |
| `Tracks` | 5 endpoints | Get tracks, user's saved tracks |
| `Playlists` | 12 endpoints | Full playlist management |
| `Search` | 1 endpoint | Search all content types |
| `Player` | 11 endpoints | Playback control and state |
| `Users` | 6 endpoints | User profiles and social features |
| `Shows` | 5 endpoints | Podcast show management |
| `Episodes` | 5 endpoints | Podcast episode management |
| `Audiobooks` | 5 endpoints | Audiobook management |
| `Categories` | 2 endpoints | Browse categories |
| `Chapters` | 2 endpoints | Audiobook chapters |
| `Markets` | 1 endpoint | Available markets |

## Error Handling

Exspotify provides structured error handling with helpful suggestions:

```elixir
case Exspotify.Albums.get_album("", token) do
  {:ok, album} -> 
    # Handle success
  {:error, %Exspotify.Error{type: :empty_id, suggestion: suggestion}} ->
    IO.puts("Error: #{suggestion}")
    # "album_id cannot be empty"
end
```

Common error types: `:unauthorized`, `:not_found`, `:rate_limited`, `:empty_id`, `:invalid_token`

## Debug Logging

Enable debug logging to troubleshoot API issues:

```elixir
# In config/dev.exs
config :exspotify, debug: true
```

This will log all HTTP requests and responses:
```
[debug] Exspotify API Request: GET https://api.spotify.com/v1/albums/123
[debug] Exspotify API Response: 200 - Success
```

## Type-Safe Responses

All API responses are parsed into structured Elixir types:

```elixir
{:ok, album} = Exspotify.Albums.get_album("4aawyAB9vmqN3uQ7FjRGTy", token)

# album is an %Exspotify.Structs.Album{} with typed fields:
album.id          # String.t()
album.name        # String.t()  
album.artists     # [%Exspotify.Structs.Artist{}]
album.images      # [%Exspotify.Structs.Image{}]
album.release_date # String.t() | nil
```

The Playlist struct normalizes track list data: the Spotify API may return it under `"tracks"` or `"items"`; both are mapped to the `tracks` field.

## Configuration Options

```elixir
config :exspotify,
  client_id: "your_client_id",           # Required for all flows
  client_secret: "your_client_secret",   # Required for all flows  
  redirect_uri: "http://localhost:4000", # Required for user auth
  token_manager: true,                   # Optional, set false when using only user auth (no client-credentials)
  base_url: "https://api.spotify.com/v1", # Optional, for testing
  debug: false                           # Optional, enables request logging
```

When exspotify is used as a dependency (e.g. in a Phoenix app), config is read from the parent app; Dotenv is only used when running exspotify standalone and `client_id` is not yet set.

## Examples

### Get User's Top Artists

```elixir
{:ok, user_token} = get_user_token() # Your user auth implementation
{:ok, top_artists} = Exspotify.Users.get_user_top_items("artists", user_token, limit: 10)

Enum.each(top_artists.items, fn artist ->
  IO.puts("#{artist.name} - #{artist.popularity}% popularity")
end)
```

### Control Playback

```elixir
# Get current playback state
{:ok, state} = Exspotify.Player.get_playback_state(user_token)

if state do
  IO.puts("Currently playing: #{state.item.name}")
  
  # Pause playback
  Exspotify.Player.pause_playback(user_token)
end
```

### Search and Create Playlist

```elixir
# Search for tracks
{:ok, results} = Exspotify.Search.search("indie rock 2023", ["track"], user_token)
track_uris = Enum.map(results["tracks"].items, & &1.uri)

# Create a playlist
{:ok, playlist} = Exspotify.Playlists.create_playlist(
  user_id, 
  "My Indie Rock Mix", 
  user_token,
  %{description: "Generated with Exspotify"}
)

# Add tracks to playlist
Exspotify.Playlists.add_items_to_playlist(
  playlist.id, 
  user_token, 
  %{uris: Enum.take(track_uris, 20)}
)
```

## Documentation

Full documentation is available on [HexDocs](https://hexdocs.pm/exspotify).

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License.

## Acknowledgments

- Built with assistance from AI tools
- [Spotify Web API](https://developer.spotify.com/documentation/web-api/) for providing a comprehensive music platform API
- The Elixir community for excellent HTTP and JSON libraries

