defmodule Exspotify.Auth do
  @moduledoc """
  Spotify OAuth flows: client credentials, authorization code (user login), and token refresh.
  """

  alias Req

  defp config, do: Application.get_all_env(:exspotify)

  @doc """
  Scopes needed for reading the user's playlists and controlling playback (e.g. Web Playback SDK).
  Use with `build_authorization_url/2` when building the login URL for a host/jukebox app.
  """
  @spec scopes_for_user_playback() :: [String.t()]
  def scopes_for_user_playback do
    [
      "user-read-private",
      "playlist-read-private",
      "playlist-read-collaborative",
      "streaming",
      "user-modify-playback-state",
      "user-read-playback-state"
    ]
  end

  def get_access_token do
    client_id = Keyword.get(config(), :client_id)
    client_secret = Keyword.get(config(), :client_secret)

    auth_string = Base.encode64("#{client_id}:#{client_secret}")

    headers = [
      {"Authorization", "Basic #{auth_string}"},
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]

    form_body = %{"grant_type" => "client_credentials"}

    case Req.post("https://accounts.spotify.com/api/token", form: form_body, headers: headers) do
      {:ok, %Req.Response{status: 200, body: decoded_body}} ->
        if is_map(decoded_body) and Map.has_key?(decoded_body, "access_token") do
          {:ok, decoded_body}
        else
          case Jason.decode(decoded_body) do
            {:ok, %{"access_token" => _token} = fully_decoded_body} -> {:ok, fully_decoded_body}
            _ -> {:error, "Failed to parse token response or unexpected format"}
          end
        end
      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, "Failed to get access token: Status #{status}, Body: #{body}"}
      {:error, exception} ->
        {:error, "HTTP request failed: #{exception.reason}"}
    end
  end

  def build_authorization_url(scopes, state \\ nil) do
    client_id = Keyword.get(config(), :client_id)
    redirect_uri = Keyword.get(config(), :redirect_uri)
    scope_string = Enum.join(scopes, " ")

    query_params = %{
      client_id: client_id,
      response_type: "code",
      redirect_uri: redirect_uri,
      scope: scope_string
    }

    query_params =
      if state do
        Map.put(query_params, :state, state)
      else
        query_params
      end

    uri = URI.parse("https://accounts.spotify.com/authorize")
    {:ok, %{uri | query: URI.encode_query(query_params)}}
  end

  def exchange_code_for_token(code) do
    client_id = Keyword.get(config(), :client_id)
    client_secret = Keyword.get(config(), :client_secret)
    redirect_uri = Keyword.get(config(), :redirect_uri)

    auth_string = Base.encode64("#{client_id}:#{client_secret}")

    headers = [
      {"Authorization", "Basic #{auth_string}"},
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]

    form_body = %{
      "grant_type" => "authorization_code",
      "code" => code,
      "redirect_uri" => redirect_uri
    }

    case Req.post("https://accounts.spotify.com/api/token", form: form_body, headers: headers) do
      {:ok, %Req.Response{status: 200, body: decoded_body}} ->
        if is_map(decoded_body) and Map.has_key?(decoded_body, "access_token") do
          {:ok, decoded_body}
        else
          # Attempt to decode if it's a JSON string
          case Jason.decode(decoded_body) do
            {:ok, %{"access_token" => _token} = fully_decoded_body} -> {:ok, fully_decoded_body}
            _ -> {:error, "Failed to parse token response or unexpected format after code exchange"}
          end
        end
      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, "Failed to exchange code for token: Status #{status}, Body: #{body}"}
      {:error, exception} ->
        {:error, "HTTP request failed during code exchange: #{exception.reason}"}
    end
  end

  def refresh_access_token(refresh_token) do
    client_id = Keyword.get(config(), :client_id)
    client_secret = Keyword.get(config(), :client_secret)

    auth_string = Base.encode64("#{client_id}:#{client_secret}")

    headers = [
      {"Authorization", "Basic #{auth_string}"},
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]

    form_body = %{
      "grant_type" => "refresh_token",
      "refresh_token" => refresh_token
    }

    case Req.post("https://accounts.spotify.com/api/token", form: form_body, headers: headers) do
      {:ok, %Req.Response{status: 200, body: decoded_body}} ->
        if is_map(decoded_body) and Map.has_key?(decoded_body, "access_token") do
          {:ok, decoded_body}
        else
          # Attempt to decode if it's a JSON string
          case Jason.decode(decoded_body) do
            {:ok, %{"access_token" => _token} = fully_decoded_body} -> {:ok, fully_decoded_body}
            _ -> {:error, "Failed to parse token response or unexpected format after refresh"}
          end
        end
      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, "Failed to refresh access token: Status #{status}, Body: #{body}"}
      {:error, exception} ->
        {:error, "HTTP request failed during token refresh: #{exception.reason}"}
    end
  end

  # ... other auth functions for different flows, token refresh, etc.
end
