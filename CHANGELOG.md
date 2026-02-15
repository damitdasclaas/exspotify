# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.2] - 2026-02-15

### Fixed

- Do not call `Mix.env/0` in a release (Mix is not available at runtime). Dotenv/loadconfig only runs when Mix is loaded (dev/test).

## [0.1.1] - 2026-02-13

### Fixed

- Load Dotenv only at runtime via module name so host apps without a Dotenv dependency no longer get a compile warning (e.g. when using Exspotify in Phoenix).

## [0.1.0] - 2025-05-30

### Added

#### Core Features
- Comprehensive Spotify Web API client with 13+ modules
- Type-safe struct parsing for all API responses
- Automatic token management with refresh support
- Professional error handling with helpful suggestions

#### API Modules
- **Albums** - Album information and user's saved albums (8 endpoints)
- **Artists** - Artist information, albums, and top tracks (3 endpoints) 
- **Tracks** - Track information and user's saved tracks (5 endpoints)
- **Playlists** - Complete playlist management (12 endpoints)
- **Search** - Search across all content types (1 endpoint)
- **Player** - Playback control and state management (11 endpoints)
- **Users** - User profiles and social features (6 endpoints)
- **Shows** - Podcast show management (5 endpoints)
- **Episodes** - Podcast episode management (5 endpoints)
- **Audiobooks** - Audiobook management (5 endpoints)
- **Chapters** - Audiobook chapter management (2 endpoints)
- **Categories** - Browse categories (2 endpoints)
- **Markets** - Available markets (1 endpoint)

#### Authentication
- Client credentials flow for app-only access
- Authorization code flow for user permissions
- Automatic token refresh with TokenManager
- Manual token management with Auth module

#### Developer Experience
- Structured error handling with suggestions
- Optional debug logging for troubleshooting
- Input validation before API calls
- Comprehensive documentation with examples
- 115+ test suite ensuring reliability

#### Data Structures
- 20+ typed structs for API responses
- Defensive parsing with sensible defaults
- Proper handling of missing/malformed data
- Consistent error types across all modules

### Technical Details
- Built on Req HTTP client
- Elixir 1.15+ compatibility
- Zero external dependencies for core functionality
- Production-ready with comprehensive test coverage 