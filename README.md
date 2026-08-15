# Exspotify

Elixir client for the [Spotify Web API](https://developer.spotify.com/documentation/web-api/). Tokens, structs, errors — not raw JSON maps.

On Hex: [exspotify](https://hex.pm/packages/exspotify). Docs: [hexdocs.pm/exspotify](https://hexdocs.pm/exspotify).

Not affiliated with Spotify.

## Why

[5songs](https://github.com/damitdasclaas/five_songs) needed Spotify in Elixir: login, playlists, playback. Existing wrappers were incomplete, stale, or left you assembling HTTP, OAuth, and response maps yourself.

So this library exists. It is the client 5songs runs on, published so other Elixir apps can use the same thing.

## What it does

- **Spotify Web API coverage** across albums, artists, tracks, playlists, search, player, users, shows, episodes, audiobooks, chapters, categories, and markets.
- **Structs instead of maps.** Responses parse into typed modules under `Exspotify.Structs` (album, track, playlist, paging, …). Nested artists and images are structs too.
- **Both OAuth flows.** Client credentials for catalog/app-only calls. Authorization code for user data and playback. `Exspotify.Auth.scopes_for_user_playback/0` is the scope set 5songs uses.
- **TokenManager** for client-credentials tokens (fetch + refresh). Turn it off with `token_manager: false` when a Phoenix app only holds user tokens.
- **`{:ok, result} | {:error, %Exspotify.Error{}}`.** Match on `type` (`:unauthorized`, `:not_found`, `:rate_limited`, `:empty_id`, …). 429s include `Retry-After` in `error.details`.
- **Rate limits stay in your process.** The client does **not** sleep on 429. Req used to block LiveView for the full Retry-After (sometimes tens of minutes). You get the error and retry on your terms.

What it does not do: the Web Playback SDK (that is JavaScript in the browser), persisting user tokens (your app stores them), acting as a Phoenix/Ueberauth plug, or auto-retrying rate limits.

## Installation

Add `exspotify` to `mix.exs`:

```elixir
def deps do
  [
    {:exspotify, "~> 0.1.4"}
  ]
end
```

You need a [Spotify Developer App](https://developer.spotify.com/dashboard) (Client ID + Secret). Development-mode apps only admit allowlisted accounts.

## Quick start

### 1. Configuration

```elixir
config :exspotify,
  client_id: "your_spotify_client_id",
  client_secret: "your_spotify_client_secret",
  redirect_uri: "http://127.0.0.1:4000/auth/callback"
```

Spotify rejects `localhost` as a redirect URI; use `127.0.0.1`.

When the host app only does user OAuth (typical Phoenix setup), disable the client-credentials TokenManager:

```elixir
config :exspotify,
  client_id: "...",
  client_secret: "...",
  redirect_uri: "http://127.0.0.1:4000/auth/callback",
  token_manager: false
```

As a dependency, config is read from the parent app. Dotenv is only used when you run Exspotify standalone and `client_id` is not set yet.

### 2. Call the API

```elixir
{:ok, token} = Exspotify.TokenManager.get_token()

{:ok, album} = Exspotify.Albums.get_album("4aawyAB9vmqN3uQ7FjRGTy", token)
album.name
# => "Global Warming"

{:ok, results} = Exspotify.Search.search("Bohemian Rhapsody", "track", token)
track = List.first(results["tracks"].items)
"#{track.name} by #{List.first(track.artists).name}"
```

User-scoped calls need a user token, not the app token:

```elixir
{:ok, playlists} = Exspotify.Playlists.get_current_users_playlists(user_token)
```

## Authentication

### Client credentials (app-only)

Catalog, search, public metadata. No user data.

```elixir
{:ok, token} = Exspotify.TokenManager.get_token()

# or without the manager:
{:ok, %{"access_token" => token}} = Exspotify.Auth.get_access_token()
```

### Authorization code (user)

Playlists, playback, profile, saved items.

```elixir
scopes = Exspotify.Auth.scopes_for_user_playback()
{:ok, auth_url} = Exspotify.Auth.build_authorization_url(scopes, "state123")
# Redirect the user to URI.to_string(auth_url)

{:ok, %{"access_token" => token, "refresh_token" => refresh}} =
  Exspotify.Auth.exchange_code_for_token(code)

{:ok, %{"access_token" => new_token}} =
  Exspotify.Auth.refresh_access_token(refresh)
```

Store the refresh token yourself. Exspotify does not keep a user session.

## API modules

| Module | Endpoints | |
|--------|-----------|--|
| `Albums` | 8 | Albums, saved albums, new releases |
| `Artists` | 3 | Artists, artist albums, top tracks |
| `Tracks` | 5 | Tracks, saved tracks |
| `Playlists` | 12 | Create, read, mutate playlists |
| `Search` | 1 | All content types |
| `Player` | 11 | Playback state and control |
| `Users` | 6 | Profiles, top items, follow |
| `Shows` | 5 | Podcasts |
| `Episodes` | 5 | Podcast episodes |
| `Audiobooks` | 5 | Audiobooks |
| `Chapters` | 2 | Audiobook chapters |
| `Categories` | 2 | Browse categories |
| `Markets` | 1 | Available markets |

Playlist track lists: Spotify sometimes sends `"tracks"`, sometimes `"items"`. Both map to the `tracks` field on the struct.

## Errors

```elixir
case Exspotify.Albums.get_album("", token) do
  {:ok, album} ->
    album.name

  {:error, %Exspotify.Error{type: :empty_id, suggestion: suggestion}} ->
    suggestion
    # => "album_id cannot be empty"

  {:error, %Exspotify.Error{type: :rate_limited, details: details}} ->
    details[:retry_after]
    # seconds, from the Retry-After header — retry later, don't block the process
end
```

Common types: `:unauthorized`, `:not_found`, `:rate_limited`, `:empty_id`, `:invalid_token`.

## Examples

### User's top artists

```elixir
{:ok, top_artists} = Exspotify.Users.get_user_top_items("artists", user_token, limit: 10)

Enum.each(top_artists.items, fn artist ->
  IO.puts("#{artist.name} - #{artist.popularity}% popularity")
end)
```

### Playback

```elixir
{:ok, state} = Exspotify.Player.get_playback_state(user_token)

if state do
  IO.puts("Currently playing: #{state.item.name}")
  Exspotify.Player.pause_playback(user_token)
end
```

### Search and create a playlist

```elixir
{:ok, results} = Exspotify.Search.search("indie rock 2023", ["track"], user_token)
track_uris = Enum.map(results["tracks"].items, & &1.uri)

{:ok, playlist} =
  Exspotify.Playlists.create_playlist(
    user_id,
    "My Indie Rock Mix",
    user_token,
    %{description: "Generated with Exspotify"}
  )

Exspotify.Playlists.add_items_to_playlist(
  playlist.id,
  user_token,
  %{uris: Enum.take(track_uris, 20)}
)
```

## Configuration

```elixir
config :exspotify,
  client_id: "your_client_id",
  client_secret: "your_client_secret",
  redirect_uri: "http://127.0.0.1:4000/auth/callback",
  token_manager: true,                    # false when you only use user tokens
  base_url: "https://api.spotify.com/v1", # override in tests
  debug: false                            # log requests in dev
```

```elixir
# config/dev.exs
config :exspotify, debug: true
```

```
[debug] Exspotify API Request: GET https://api.spotify.com/v1/albums/123
[debug] Exspotify API Response: 200 - Success
```

## Used by

[5songs](https://github.com/damitdasclaas/five_songs) — party game on your Spotify playlists.

## License

MIT. See [LICENSE.md](LICENSE.md).
