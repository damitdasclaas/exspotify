defmodule Exspotify.Error do
  @moduledoc """
  Error types and utilities for the Exspotify library.

  Provides structured error handling with specific error types and helpful context.
  """

  @type error_reason ::
    # Input validation errors
    :invalid_id
    | :empty_id
    | :invalid_token
    | :empty_token
    | :invalid_type
    | :empty_list

    # HTTP/API errors
    | :unauthorized
    | :forbidden
    | :not_found
    | :rate_limited
    | :server_error
    | :bad_request
    | :service_unavailable

    # Client errors
    | :network_error
    | :timeout
    | :json_decode_error
    | :unexpected_response

  @type t :: %__MODULE__{
    type: error_reason(),
    message: String.t(),
    details: map() | nil,
    status: integer() | nil
  }

  defstruct [:type, :message, :details, :status]

  @doc """
  Creates a new error struct with the given type and message.
  """
  @spec new(error_reason(), String.t(), map() | nil, integer() | nil) :: t()
  def new(type, message, details \\ nil, status \\ nil) do
    %__MODULE__{
      type: type,
      message: message,
      details: details,
      status: status
    }
  end

  @doc """
  Validates that an ID is present and non-empty.
  """
  @spec validate_id(String.t() | nil, String.t()) :: :ok | {:error, t()}
  def validate_id(nil, field_name) do
    {:error, new(:empty_id, "#{field_name} cannot be nil", %{field: field_name})}
  end

  def validate_id("", field_name) do
    {:error, new(:empty_id, "#{field_name} cannot be empty", %{field: field_name})}
  end

  def validate_id(id, _field_name) when is_binary(id) and byte_size(id) > 0 do
    :ok
  end

  def validate_id(id, field_name) do
    {:error, new(:invalid_id, "#{field_name} must be a non-empty string, got: #{inspect(id)}", %{field: field_name, value: id})}
  end

  @doc """
  Validates that a token is present and non-empty.
  """
  @spec validate_token(String.t() | nil) :: :ok | {:error, t()}
  def validate_token(nil) do
    {:error, new(:empty_token, "Access token cannot be nil")}
  end

  def validate_token("") do
    {:error, new(:empty_token, "Access token cannot be empty")}
  end

  def validate_token(token) when is_binary(token) and byte_size(token) > 0 do
    :ok
  end

  def validate_token(token) do
    {:error, new(:invalid_token, "Access token must be a non-empty string, got: #{inspect(token)}", %{value: token})}
  end

  @doc """
  Validates that a list is present and non-empty.
  """
  @spec validate_list([any()], String.t()) :: :ok | {:error, t()}
  def validate_list([], field_name) do
    {:error, new(:empty_list, "#{field_name} cannot be empty", %{field: field_name})}
  end

  def validate_list(list, _field_name) when is_list(list) and length(list) > 0 do
    :ok
  end

  def validate_list(value, field_name) do
    {:error, new(:invalid_type, "#{field_name} must be a non-empty list, got: #{inspect(value)}", %{field: field_name, value: value})}
  end

  @doc """
  Converts HTTP status codes and responses to structured errors.
  """
  @spec from_http_response(integer(), any()) :: t()
  def from_http_response(400, body) do
    new(:bad_request, "Bad request - check your parameters", %{response_body: body}, 400)
  end

  def from_http_response(401, body) do
    new(:unauthorized, "Invalid or expired access token", %{response_body: body}, 401)
  end

  def from_http_response(403, body) do
    new(:forbidden, "Insufficient permissions or forbidden request", %{response_body: body}, 403)
  end

  def from_http_response(404, body) do
    new(:not_found, "Resource not found", %{response_body: body}, 404)
  end

  def from_http_response(429, body) do
    retry_after = extract_retry_after(body)
    message = if retry_after, do: "Rate limit exceeded. Retry after #{retry_after} seconds", else: "Rate limit exceeded"
    new(:rate_limited, message, %{response_body: body, retry_after: retry_after}, 429)
  end

  def from_http_response(500, body) do
    new(:server_error, "Internal server error", %{response_body: body}, 500)
  end

  def from_http_response(502, body) do
    new(:service_unavailable, "Service temporarily unavailable", %{response_body: body}, 502)
  end

  def from_http_response(503, body) do
    new(:service_unavailable, "Service temporarily unavailable", %{response_body: body}, 503)
  end

  def from_http_response(status, body) when status >= 400 do
    new(:server_error, "HTTP error #{status}", %{response_body: body}, status)
  end

  @doc """
  Creates a network error.
  """
  @spec network_error(any()) :: t()
  def network_error(reason) do
    message = case reason do
      %{reason: :timeout} -> "Request timed out"
      %{reason: :nxdomain} -> "DNS resolution failed"
      %{reason: :econnrefused} -> "Connection refused"
      _ -> "Network error: #{inspect(reason)}"
    end

    new(:network_error, message, %{reason: reason})
  end

  @doc """
  Creates a JSON decode error.
  """
  @spec json_decode_error(any()) :: t()
  def json_decode_error(data) do
    new(:json_decode_error, "Failed to decode JSON response", %{data: data})
  end

  # Private helper to extract retry-after from rate limit responses
  defp extract_retry_after(body) when is_map(body) do
    body["retry_after"] || body["Retry-After"]
  end

  defp extract_retry_after(_), do: nil
end
