defmodule Exspotify.Client do
  @moduledoc """
  HTTP client for interacting with the Spotify Web API.

  This module is responsible for making authenticated requests to the Spotify API,
  handling JSON encoding/decoding, and basic error handling. It expects a valid
  access token to be provided for each request.
  """

  # Placeholder for the main request/5 function and public interface functions.

  # Returns the base URL for the Spotify Web API from config, or defaults to v1 endpoint.
  defp base_url do
    Application.get_env(:exspotify, :base_url, "https://api.spotify.com/v1")
  end

  @doc false
  @spec request(atom, String.t(), list, any, String.t()) :: any
  # method: :get, :post, :put, :delete
  # path: API endpoint path (e.g., "/tracks/123")
  # headers: additional headers (list of tuples)
  # body: request body (for POST/PUT), can be nil
  # token: OAuth access token
  defp request(method, path, headers, body, token) do
    url = base_url() <> path
    auth_header = {"Authorization", "Bearer #{token}"}

    # For POST/PUT, encode body as JSON and set Content-Type
    {final_body, final_headers} =
      case method do
        m when m in [:post, :put] ->
          json_body = Jason.encode!(body)
          {json_body, [{"Content-Type", "application/json"} | headers]}
        _ ->
          {nil, headers}
      end

    all_headers = [auth_header | final_headers]

    req_opts =
      [
        method: method,
        url: url,
        headers: all_headers
      ] ++
        (if final_body, do: [body: final_body], else: [])

    case Req.request(req_opts) do
      {:ok, %Req.Response{status: status, body: resp_body}} when status in 200..299 ->
        cond do
          is_map(resp_body) -> {:ok, resp_body}
          is_binary(resp_body) ->
            case Jason.decode(resp_body) do
              {:ok, decoded} -> {:ok, decoded}
              _ -> {:ok, resp_body}
            end
          true -> {:ok, resp_body}
        end

      {:ok, %Req.Response{status: status, body: error_body}} ->
        {:error, %{status: status, body: error_body, message: "API Error"}}

      {:error, exception} ->
        {:error, %{reason: exception, message: "HTTP Request Error"}}
    end
  end

  @doc """
  Makes a GET request to the given Spotify API path with optional headers and access token.
  """
  @spec get(String.t(), list, String.t()) :: any
  def get(path, headers \\ [], token) do
    request(:get, path, headers, nil, token)
  end

  @doc """
  Makes a POST request to the given Spotify API path with a body, optional headers, and access token.
  """
  @spec post(String.t(), any, list, String.t()) :: any
  def post(path, body, headers \\ [], token) do
    request(:post, path, headers, body, token)
  end

  @doc """
  Makes a PUT request to the given Spotify API path with a body, optional headers, and access token.
  """
  @spec put(String.t(), any, list, String.t()) :: any
  def put(path, body, headers \\ [], token) do
    request(:put, path, headers, body, token)
  end

  @doc """
  Makes a DELETE request to the given Spotify API path with optional headers and access token.
  """
  @spec delete(String.t(), list, String.t()) :: any
  def delete(path, headers \\ [], token) do
    request(:delete, path, headers, nil, token)
  end
end
