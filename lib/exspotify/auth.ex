defmodule Exspotify.Auth do
  alias Req

  defp config, do: Application.get_all_env(:exspotify)

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

  # ... other auth functions for different flows, token refresh, etc.
end
