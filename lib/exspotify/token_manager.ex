defmodule Exspotify.TokenManager do
  use GenServer

  alias Exspotify.Auth

  # --- Client API ---
  def start_link(opts) do
    GenServer.start_link(__MODULE__, Keyword.new(opts), name: __MODULE__)
  end

  def get_token do
    GenServer.call(__MODULE__, :get_token)
  end

  # --- Server Callbacks ---
  @impl true
  def init(_opts) do
    # _opts: For future use (e.g., different token strategies, initial token data).
    schedule_fetch_token() # Initial fetch.
    {:ok, %{token_data: nil, refresh_timer: nil}}
  end

  @impl true
  # Called when token is requested but not yet in state.
  def handle_call(:get_token, _from, %{token_data: nil} = state) do
    # Fetch synchronously for the first caller to ensure immediate token availability.
    case fetch_and_store_token() do
      {:ok, new_token_data} ->
        new_state = schedule_refresh(%{state | token_data: new_token_data})
        {:reply, {:ok, new_token_data["access_token"]}, new_state}
      {:error, reason} ->
        schedule_fetch_token(5_000) # Retry fetch in 5 seconds on failure.
        {:reply, {:error, reason}, state}
    end
  end

  # Called when token is requested and already in state.
  def handle_call(:get_token, _from, %{token_data: token_data} = state) do
    {:reply, {:ok, token_data["access_token"]}, state}
  end

  @impl true
  # Handles scheduled token fetch/refresh messages.
  def handle_info(:fetch_token, state) do
    if state.refresh_timer, do: Process.cancel_timer(state.refresh_timer)

    case fetch_and_store_token() do
      {:ok, new_token_data} ->
        new_state = schedule_refresh(%{state | token_data: new_token_data})
        {:noreply, new_state}
      {:error, _reason} ->
        # Log error and retry fetch if a scheduled refresh fails.
        Process.send_after(self(), :fetch_token, 60_000) # Retry in 1 minute.
        {:noreply, %{state | refresh_timer: nil}} # Clear timer ref.
    end
  end

  # --- Private Helpers ---
  defp schedule_fetch_token(interval \\ 0) do
    Process.send_after(self(), :fetch_token, interval)
  end

  defp fetch_and_store_token() do
    # Uses Client Credentials flow. For user tokens, this logic would differ.
    Auth.get_access_token()
  end

  # Schedules next token refresh based on 'expires_in'.
  defp schedule_refresh(%{token_data: %{"expires_in" => expires_in_seconds}} = state) do
    # Refresh 5 minutes (300s) before actual expiry.
    refresh_interval_ms = max(0, (expires_in_seconds - 300) * 1000)

    if state.refresh_timer, do: Process.cancel_timer(state.refresh_timer)

    new_timer_ref = Process.send_after(self(), :fetch_token, refresh_interval_ms)
    %{state | refresh_timer: new_timer_ref}
  end

  # Fallback for schedule_refresh if 'expires_in' is missing from token_data.
  defp schedule_refresh(state) do
    # This might indicate an issue with the token response.
    IO.inspect("Warning: TokenManager missing 'expires_in'. Retrying fetch in 5 mins.", label: "TokenManager")
    if state.refresh_timer, do: Process.cancel_timer(state.refresh_timer)
    new_timer_ref = Process.send_after(self(), :fetch_token, 300_000) # Retry in 5 minutes.
    %{state | refresh_timer: new_timer_ref}
  end
end
