defmodule Exspotify.Pagination do
  @moduledoc """
  Generic helper for fetching all items from paginated Spotify API endpoints.

  **Warning:** This may make a large number of requests if the resource contains many items.
  You can limit the number of items fetched with the `max_items` argument (default: 200).
  """

  @spec fetch_all((keyword -> {:ok, map} | {:error, any}), keyword, integer) :: [map] | {:error, any}
  def fetch_all(fetch_page_fun, opts \\ [], max_items \\ 200) do
    limit = min(50, max_items)
    do_fetch_all(fetch_page_fun, Keyword.put(opts, :limit, limit), 0, max_items, [])
  end

  defp do_fetch_all(fetch_page_fun, opts, offset, max_items, acc) do
    page_opts = Keyword.put(opts, :offset, offset)
    case fetch_page_fun.(page_opts) do
      {:ok, %{"items" => items, "next" => next_url}} ->
        new_acc = acc ++ items
        cond do
          next_url == nil -> Enum.take(new_acc, max_items)
          length(new_acc) >= max_items -> Enum.take(new_acc, max_items)
          true ->
            do_fetch_all(fetch_page_fun, opts, offset + Keyword.get(opts, :limit, 50), max_items, new_acc)
        end
      {:ok, %{"items" => items}} ->
        Enum.take(acc ++ items, max_items)
      {:error, _} = err -> err
    end
  end
end
