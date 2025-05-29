# Building an Elixir Wrapper for the Spotify Web API

This document outlines the steps, best practices, and important considerations for creating an API wrapper for the Spotify Web API using Elixir.

## 1. Introduction to API Wrappers

An API wrapper is a library or module that simplifies interaction with an external API. It abstracts away the complexities of HTTP requests, authentication, data parsing, and error handling, providing a more idiomatic and easier-to-use interface in the target programming language (in this case, Elixir).

**Benefits of an API Wrapper:**

*   **Simplicity:** Provides a simpler, more intuitive interface than raw HTTP calls.
*   **Abstraction:** Hides implementation details of API communication.
*   **Reusability:** Encapsulates common API interactions for easy reuse.
*   **Maintainability:** Centralizes API logic, making updates easier if the underlying API changes.
*   **Error Handling:** Can provide consistent error handling and reporting.
*   **Language Idiomatic:** Leverages the features and conventions of the programming language (e.g., functional patterns in Elixir).

## 2. Understanding the Spotify Web API

Before building the wrapper, it's crucial to understand the Spotify Web API. Key aspects include:

*   **Documentation:** The primary source of truth is the [Spotify Web API Documentation](https://developer.spotify.com/documentation/web-api).
*   **Base URL:** API requests are typically made to `https://api.spotify.com/v1/`.
*   **Authentication:** Spotify uses OAuth 2.0. You'll need to handle different authorization flows (e.g., Authorization Code, Client Credentials). Refer to:
    *   [Authorization Concepts](https://developer.spotify.com/documentation/web-api/concepts/authorization)
    *   [Authorization Code Flow](https://developer.spotify.com/documentation/web-api/tutorials/authorization-code)
    *   [Client Credentials Flow](https://developer.spotify.com/documentation/web-api/tutorials/client-credentials)
    *   Access Tokens are required for most API calls and expire, requiring a refresh mechanism.
*   **Rate Limits:** Be aware of [Rate Limits](https://developer.spotify.com/documentation/web-api/concepts/rate-limits) to prevent your application from being blocked. Implement retry mechanisms with backoff strategies.
*   **Scopes:** Your application will need to request specific [Scopes](https://developer.spotify.com/documentation/web-api/concepts/scopes) to access different parts of a user's data or perform certain actions.
*   **Data Format:** The API primarily uses JSON for requests and responses.
*   **Spotify URIs and IDs:** Understand how Spotify identifies artists, albums, tracks, etc. using [Spotify URIs and IDs](https://developer.spotify.com/documentation/web-api/concepts/spotify-uris-ids).
*   **Endpoints:** Familiarize yourself with the available [API Reference](https://developer.spotify.com/documentation/web-api/reference) to understand the various resources and actions you can perform.

## 3. Step-by-Step Guide to Building the Elixir Wrapper

### 3.1. Project Setup

1.  **New Mix Project:**
    ```bash
    mix new exspotify --sup
    cd exspotify
    ```
2.  **Add Dependencies:**
    In your `mix.exs` file, add necessary HTTP client (e.g., `Finch`, `Tesla`, `HTTPoison`), JSON parser (e.g., `Jason`, `Poison`), and potentially OAuth2 libraries.
    ```elixir
    defp deps do
      [
        {:finch, "~> 0.16"}, # Or another HTTP client
        {:jason, "~> 1.4"},  # Or another JSON library
        # Potentially an OAuth2 library like :oauth2
      ]
    end
    ```
    Then run `mix deps.get`.

### 3.2. Configuration

Store your Spotify Client ID and Client Secret securely. Using environment variables is a good practice. We'll use the `dotenv_elixir` library to load these from a `.env` file during development and testing.

1.  **Add `dotenv_elixir` to `mix.exs`:**
    Ensure you have `{:dotenv, "~> 3.0.0", only: [:dev, :test]}` in your `deps` function in `mix.exs` and run `mix deps.get`.

2.  **Create a `.env` file:**
    In the root of your project, create a `.env` file (this is usually in `.gitignore`):
    ```
    SPOTIFY_CLIENT_ID="your_spotify_client_id"
    SPOTIFY_CLIENT_SECRET="your_spotify_client_secret"
    SPOTIFY_REDIRECT_URI="your_redirect_uri"
    ```
    Replace the placeholders with your actual Spotify application credentials.

3.  **Accessing variables in `config/config.exs`:**
    The `dotenv_elixir` application will automatically load the variables from `.env` into the environment when your application starts in `:dev` or `:test` mode (e.g., with `iex -S mix`). You can then access them in your configuration files:

    ```elixir
    # config/config.exs
    config :exspotify,
      client_id: System.get_env("SPOTIFY_CLIENT_ID"),
      client_secret: System.get_env("SPOTIFY_CLIENT_SECRET"),
      redirect_uri: System.get_env("SPOTIFY_REDIRECT_URI"),
      base_url: "https://api.spotify.com/v1"

    config :exspotify, Finch,
      name: Exspotify.Finch # If using Finch
    ```

    **Note on Production:** `dotenv_elixir` is generally not recommended for production environments that use Elixir releases (like Distillery or built-in releases) because it loads variables at runtime, which can be too late for compile-time configuration. For production, you should rely on setting environment variables directly in your deployment environment. The `only: [:dev, :test]` option ensures it's only used during development.

### 3.3. Authentication Module

Create a module to handle authentication logic.

*   `Exspotify.Auth`
    *   Functions to get an access token (e.g., using Client Credentials flow for server-to-server calls).
    *   Functions to build authorization URLs for user-based flows (Authorization Code).
    *   Functions to exchange an authorization code for an access token.
    *   Functions to refresh an access token.
    *   Securely store and manage tokens (e.g., in a GenServer, ETS, or a database for persistent storage if needed).

**Example (Client Credentials Flow with Finch and Jason):**

```elixir
defmodule Exspotify.Auth do
  alias Exspotify.Finch # Assuming Finch is configured with this name

  defp config, do: Application.get_all_env(:exspotify)

  def get_access_token do
    client_id = Keyword.get(config(), :client_id)
    client_secret = Keyword.get(config(), :client_secret)

    auth_string = Base.encode64("#{client_id}:#{client_secret}")

    body = URI.encode_query(%{"grant_type" => "client_credentials"})

    request = Finch.build(
      :post,
      "https://accounts.spotify.com/api/token",
      [{"Authorization", "Basic #{auth_string}"}, {"Content-Type", "application/x-www-form-urlencoded"}],
      body
    )

    case Finch.request(request, Finch) do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"access_token" => token} = decoded_body} -> {:ok, decoded_body} # Store and return the token
          {:error, reason} -> {:error, "Failed to parse token response: #{reason}"}
        end
      {:ok, %Finch.Response{status: status, body: body}} ->
        {:error, "Failed to get access token: Status #{status}, Body: #{body}"}
      {:error, reason} ->
        {:error, "HTTP request failed: #{reason}"}
    end
  end

  # ... other auth functions for different flows, token refresh, etc.
end
```

### 3.4. HTTP Client Module

Create a generic client module to handle making requests.

*   `Exspotify.Client`
    *   Functions like `get/3`, `post/3`, `put/3`, `delete/3`.
    *   These functions should:
        *   Accept the path, headers, and body.
        *   Retrieve a valid access token (potentially from the `Auth` module or a token store).
        *   Prepend the base API URL.
        *   Include the `Authorization: Bearer <access_token>` header.
        *   Handle JSON encoding/decoding.
        *   Basic error handling for HTTP errors or rate limiting (can be enhanced later).

**Example (using Finch):**

```elixir
defmodule Exspotify.Client do
  alias Exspotify.Finch # Assuming Finch is configured with this name

  defp base_url, do: Application.get_env(:exspotify, :base_url, "https://api.spotify.com/v1")

  defp request(method, path, headers \ [], body \ nil, token) do
    url = base_url() <> path
    auth_header = {"Authorization", "Bearer #{token}"}
    all_headers = [auth_header | headers] # Ensure content-type is set appropriately for POST/PUT

    case Finch.request(Finch.build(method, url, all_headers, body), Finch) do
      {:ok, %Finch.Response{status: status, body: response_body}} when status in 200..299 ->
        case Jason.decode(response_body) do
          {:ok, decoded_json} -> {:ok, decoded_json}
          {:error, _} -> {:ok, response_body} # If not JSON, return raw body for success
        end
      {:ok, %Finch.Response{status: status, body: error_body}} ->
        # More sophisticated error parsing can be done here
        {:error, %{status: status, body: error_body, message: "API Error"}}
      {:error, reason} ->
        {:error, %{reason: reason, message: "HTTP Request Error"}}
    end
  end

  # Public functions that fetch the token first
  def get(path, headers \ [], token) do # Token should be managed and passed
    request(:get, path, headers, nil, token)
  end

  def post(path, body, headers \ [], token) do
    # Ensure body is JSON encoded if required by Spotify for the endpoint
    json_body = Jason.encode!(body)
    all_headers = [{"Content-Type", "application/json"} | headers]
    request(:post, path, all_headers, json_body, token)
  end

  # ... put/3, delete/3
end
```
*Note: Token management (fetching, refreshing, passing to `Client` functions) is a key aspect. You might have a GenServer that holds the current token and refreshes it when needed.*

### 3.5. Resource Modules

Create modules for different API resources (e.g., Albums, Artists, Tracks, Playlists).

*   `Exspotify.Albums`
*   `Exspotify.Artists`
*   `Exspotify.Tracks`
*   etc.

Each module will use the `Exspotify.Client` to make requests. Functions should be named intuitively, mapping to API endpoints.

**Example (`Exspotify.Tracks`):**

```elixir
defmodule Exspotify.Tracks do
  alias Exspotify.Client

  @doc """
  Get Spotify catalog information for a single track identified by its unique Spotify ID.
  https://developer.spotify.com/documentation/web-api/reference/get-track
  """
  def get_track(track_id, token, opts \ []) do
    query_params = URI.encode_query(opts) # e.g., market
    path = "/tracks/#{track_id}" <> if(query_params != "", do: "?#{query_params}", else: "")
    Client.get(path, [], token)
  end

  @doc """
  Get Spotify catalog information for multiple tracks based on their Spotify IDs.
  https://developer.spotify.com/documentation/web-api/reference/get-several-tracks
  """
  def get_several_tracks(track_ids, token, opts \ []) when is_list(track_ids) do
    ids_param = Enum.join(track_ids, ",")
    query_params = URI.encode_query(Map.put(opts, :ids, ids_param))
    path = "/tracks?#{query_params}"
    Client.get(path, [], token)
  end

  # ... other track-related functions
end
```

### 3.6. Structs for API Responses (Optional but Recommended)

Define Elixir structs to represent common Spotify API response objects (Track, Artist, Album, etc.). This provides better type safety and makes working with responses easier.

```elixir
defmodule Exspotify.Objects.Track do
  @moduledoc "Represents a Spotify Track object"
  @enforce_keys [:id, :name, :uri] # Example of enforcing some keys
  defstruct [
    :album,
    :artists,
    :available_markets,
    :disc_number,
    :duration_ms,
    :explicit,
    :external_ids,
    :external_urls,
    :href,
    :id,
    :is_playable,
    :linked_from,
    :restrictions,
    :name,
    :popularity,
    :preview_url,
    :track_number,
    :type,
    :uri,
    :is_local
  ]

  # You can add a `from_map/1` function to parse the JSON into the struct
  def from_map(map) when is_map(map) do
    # Basic example, more robust parsing might be needed
    # Consider libraries like ExConstructor or manual mapping
    struct(__MODULE__, Map.to_list(map) |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end))
  end
end
```
Your client or resource modules can then parse the JSON into these structs.

### 3.7. Error Handling

*   **Consistent Error Tuples:** Return `{:ok, result}` or `{:error, reason}`. The `reason` can be a map or struct containing details like status code, error message from Spotify, etc.
*   **Custom Error Structs:** Define custom error structs for different error types (e.g., `Exspotify.Error.RateLimitError`, `Exspotify.Error.AuthenticationError`).
*   **Retry Mechanisms:** Implement retry logic (e.g., with exponential backoff) for transient errors or rate limiting, possibly in the `Client` module or using a library like `Retry`.

### 3.8. Testing

Write comprehensive tests for your wrapper:
*   Unit tests for individual functions.
*   Integration tests that make real (but limited and non-destructive) calls to the Spotify API (use with caution, mock where possible).
*   Mock HTTP responses using libraries like `Mox` to test your client and resource modules without hitting the actual API.

## 4. Best Practices for API Wrappers in Elixir

*   **Functional Principles:**
    *   **Immutability:** Embrace Elixir's immutable data structures.
    *   **Pure Functions:** Write pure functions where possible, especially in resource modules.
    *   **Pattern Matching:** Use pattern matching extensively for parsing responses and handling different outcomes.
    *   **Piping:** Leverage the pipe operator (`|>`) for clean data transformation pipelines.
*   **Concurrency and Asynchronicity:**
    *   For multiple independent API calls, consider using `Task.async_stream` or similar patterns to make requests concurrently.
    *   If your HTTP client supports it (like Finch with connection pools), it will handle some concurrency benefits.
*   **Modularity:** Keep modules focused (e.g., `Auth`, `Client`, separate resource modules).
*   **Clear Naming:** Use clear and consistent naming for modules and functions, ideally mirroring Spotify's terminology.
*   **Documentation:** Provide good ` @moduledoc` and ` @doc` for all public modules and functions. Include examples.
*   **Configuration:** Make the wrapper configurable (client ID, secret, base URL, timeouts) via application environment.
*   **Dependency Management:** Keep dependencies minimal and up-to-date.
*   **Supervisor Tree:** If your wrapper involves stateful processes (like a token manager GenServer), ensure they are properly supervised.
*   **Avoid Global State:** Pass necessary data (like access tokens) explicitly to functions rather than relying on a global process registry directly in every function, unless it's a well-encapsulated internal mechanism.
*   **Return Rich Error Information:** Don't just return `:error`. Provide context about what went wrong.

## 5. Important Considerations for Spotify API

*   **Token Management:** Robust access token fetching, storage, and refreshing is critical. Consider a GenServer to manage the token lifecycle.
*   **Market Parameter:** Many endpoints accept a `market` parameter. Consider how your wrapper will handle this (e.g., default, allow user to specify).
*   **Track Relinking:** Be aware of [Track Relinking](https://developer.spotify.com/documentation/web-api/concepts/track-relinking) if you need to handle tracks that might not be available in a user's market.
*   **User Authorization:** For operations that require user context (e.g., managing playlists, accessing user profile), implement the Authorization Code flow or Authorization Code with PKCE. This is more complex than Client Credentials.
    *   **Note on Local Testing with Redirect URIs:** When testing user authorization flows locally, Spotify often requires an `https://` redirect URI. If you're using `https://localhost:...` as your redirect URI in the Spotify Developer Dashboard, you will likely need a tool like `ngrok` to create an HTTPS tunnel to your local development server. This is because your local server might only be running HTTP, and the browser needs to successfully connect to the redirect URI via HTTPS after user authentication on Spotify's side.
*   **Idempotency:** If relevant for POST/PUT/DELETE operations, understand Spotify's idempotency guarantees (or lack thereof).
*   **API Versioning:** While the current version is v1, be mindful that APIs can change. Design for some flexibility.

## 6. Example: Managing the Access Token with a GenServer

For a more robust solution, especially for server-side applications using Client Credentials or managing user tokens, a GenServer can manage the token and refresh it automatically.

```elixir
defmodule Exspotify.TokenManager do
  use GenServer

  # Client API
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def get_token do
    GenServer.call(__MODULE__, :get_token)
  end

  # Server Callbacks
  @impl true
  def init(_opts) do
    # opts could include initial token or strategy (e.g. :client_credentials)
    # Schedule first fetch or load from persistent store
    schedule_fetch_token()
    {:ok, %{token_data: nil, refresh_timer: nil}}
  end

  @impl true
  def handle_call(:get_token, _from, %{token_data: nil} = state) do
    # If no token, fetch synchronously for the first caller
    case fetch_and_store_token() do
      {:ok, new_token_data} ->
        schedule_refresh(new_token_data)
        {:reply, {:ok, new_token_data["access_token"]}, %{state | token_data: new_token_data}}
      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  def handle_call(:get_token, _from, %{token_data: token_data} = state) do
    # Token exists, return it
    {:reply, {:ok, token_data["access_token"]}, state}
  end

  @impl true
  def handle_info(:fetch_token, state) do
    case fetch_and_store_token() do
      {:ok, new_token_data} ->
        schedule_refresh(new_token_data)
        {:noreply, %{state | token_data: new_token_data}}
      {:error, _reason} ->
        # Log error, maybe retry after a shorter interval
        schedule_fetch_token(60_000) # Retry in 1 minute
        {:noreply, state}
    end
  end

  defp schedule_fetch_token(interval \ 0) do
    Process.send_after(self(), :fetch_token, interval)
  end

  defp fetch_and_store_token() do
    # Using the Auth module defined earlier
    Exspotify.Auth.get_access_token()
    # In a real app, you'd get a map like %{"access_token" => "...", "expires_in" => 3600, ...}
  end

  defp schedule_refresh(%{"expires_in" => expires_in_seconds} = token_data) do
    # Schedule refresh before it expires (e.g., 5 minutes before)
    refresh_interval_ms = (expires_in_seconds - 300) * 1000
    if refresh_interval_ms > 0 do
      timer_ref = Process.send_after(self(), :fetch_token, refresh_interval_ms)
      # Cancel previous timer if any, and store new one
      # (Ensure previous timer ref is stored in state and cancelled if present)
      %{token_data | refresh_timer: timer_ref} # Update state with new timer
    else
      # Token expires very soon or already expired, refresh immediately
      schedule_fetch_token()
      token_data
    end
  end
  defp schedule_refresh(_token_data), do: schedule_fetch_token(300_000) # Default if no expires_in

end
```

Then your `Client` module or resource modules would call `Exspotify.TokenManager.get_token()` to retrieve the current access token. Remember to add `TokenManager` to your application's supervisor tree.

This detailed guide should provide a solid foundation for building your Elixir Spotify API wrapper. Remember to consult the official Spotify documentation frequently as you implement different endpoints.
