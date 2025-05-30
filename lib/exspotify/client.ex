defmodule Exspotify.Client do
  @moduledoc """
  HTTP client for interacting with the Spotify Web API.

  This module is responsible for making authenticated requests to the Spotify API,
  handling JSON encoding/decoding, and structured error handling. It expects a valid
  access token to be provided for each request.

  ## Debug Logging

  Enable debug logging to see API requests and responses:

      config :exspotify, debug: true

  This will log all HTTP requests made to the Spotify API for troubleshooting.
  """

  alias Exspotify.Error
  require Logger

  # Returns the base URL for the Spotify Web API from config, or defaults to v1 endpoint.
  defp base_url do
    Application.get_env(:exspotify, :base_url, "https://api.spotify.com/v1")
  end

  # Check if debug logging is enabled
  defp debug_enabled? do
    Application.get_env(:exspotify, :debug, false)
  end

  @doc false
  @spec request(atom, String.t(), list, any, String.t()) :: {:ok, any()} | {:error, Error.t()}
  # method: :get, :post, :put, :delete
  # path: API endpoint path (e.g., "/tracks/123")
  # headers: additional headers (list of tuples)
  # body: request body (for POST/PUT), can be nil
  # token: OAuth access token
  defp request(method, path, headers, body, token) do
    url = base_url() <> path
    auth_header = {"Authorization", "Bearer #{token}"}

    if debug_enabled?() do
      Logger.debug("Exspotify API Request: #{String.upcase(to_string(method))} #{url}")
      if body && body != %{} do
        Logger.debug("Exspotify Request Body: #{inspect(body)}")
      end
    end

    # For POST/PUT/DELETE, encode body as JSON and set Content-Type
    case method do
      m when m in [:post, :put, :delete] ->
        case Jason.encode(body) do
          {:ok, json_body} ->
            final_body = json_body
            final_headers = [{"Content-Type", "application/json"} | headers]
            make_request(url, method, all_headers(auth_header, final_headers), final_body)
          {:error, encode_error} ->
            if debug_enabled?() do
              Logger.error("Exspotify JSON Encode Error: #{inspect(encode_error)}")
            end
            {:error, Error.json_decode_error(%{encode_error: encode_error, data: body})}
        end
      _ ->
        final_body = nil
        final_headers = headers
        make_request(url, method, all_headers(auth_header, final_headers), final_body)
    end
  end

  defp all_headers(auth_header, headers), do: [auth_header | headers]

  defp make_request(url, method, headers, body) do
    req_opts =
      [
        method: method,
        url: url,
        headers: headers
      ] ++
        (if body, do: [body: body], else: [])

    case Req.request(req_opts) do
      {:ok, %Req.Response{status: status, body: resp_body}} when status in 200..299 ->
        if debug_enabled?() do
          Logger.debug("Exspotify API Response: #{status} - Success")
        end
        parse_success_response(resp_body)

      {:ok, %Req.Response{status: status, body: error_body}} ->
        if debug_enabled?() do
          Logger.warning("Exspotify API Response: #{status} - #{inspect(error_body)}")
        end
        {:error, Error.from_http_response(status, error_body)}

      {:error, exception} ->
        if debug_enabled?() do
          Logger.error("Exspotify Network Error: #{inspect(exception)}")
        end
        {:error, Error.network_error(exception)}
    end
  end

  # Parse successful responses, handling JSON decoding
  defp parse_success_response(resp_body) do
    cond do
      is_map(resp_body) ->
        {:ok, resp_body}
      is_binary(resp_body) ->
        case Jason.decode(resp_body) do
          {:ok, decoded} -> {:ok, decoded}
          {:error, decode_error} ->
            if debug_enabled?() do
              Logger.error("Exspotify JSON Decode Error: #{inspect(decode_error)}")
            end
            {:error, Error.json_decode_error(resp_body)}
        end
      true ->
        {:ok, resp_body}
    end
  end

  @doc """
  Makes a GET request to the given Spotify API path with optional headers and access token.
  """
  @spec get(String.t(), list, String.t()) :: {:ok, any()} | {:error, Error.t()}
  def get(path, headers \\ [], token) do
    request(:get, path, headers, nil, token)
  end

  @doc """
  Makes a POST request to the given Spotify API path with a body, optional headers, and access token.
  """
  @spec post(String.t(), any, list, String.t()) :: {:ok, any()} | {:error, Error.t()}
  def post(path, body, headers \\ [], token) do
    request(:post, path, headers, body, token)
  end

  @doc """
  Makes a PUT request to the given Spotify API path with a body, optional headers, and access token.
  """
  @spec put(String.t(), any, list, String.t()) :: {:ok, any()} | {:error, Error.t()}
  def put(path, body, headers \\ [], token) do
    request(:put, path, headers, body, token)
  end

  @doc """
  Makes a DELETE request to the given Spotify API path with a body, optional headers, and access token.
  """
  @spec delete(String.t(), any, list, String.t()) :: {:ok, any()} | {:error, Error.t()}
  def delete(path, body, headers \\ [], token) do
    request(:delete, path, headers, body, token)
  end
end
