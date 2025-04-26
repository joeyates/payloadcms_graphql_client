defmodule PayloadcmsGraphqlClient.PaginatedQuery do
  @enforce_keys [:name, :docs, :endpoint]
  defstruct [
    :name,
    :docs,
    :endpoint,
    options: %{},
    page: 1
  ]

  @type t :: %__MODULE__{
          name: atom(),
          docs: String.t(),
          endpoint: String.t(),
          options: map(),
          page: integer()
        }

  def fetch(%__MODULE__{} = paginated) do
    query = to_query(paginated)

    paginated.endpoint
    |> Req.post!(
      json: %{query: query},
      headers: [{"Content-Type", "application/json"}],
      decode_json: [keys: :atoms]
    )
    |> handle_response(paginated)
  end

  defp handle_response(%Req.Response{status: 200, body: body}, paginated) do
    has_next_page = get_in(body, [:data, paginated.name, :hasNextPage])
    results = get_in(body, [:data, paginated.name, :docs])

    if has_next_page do
      paginated = next_page(paginated)
      results ++ fetch(paginated)
    else
      results
    end
  end

  defp to_query(%__MODULE__{name: name, docs: docs, options: options, page: page}) do
    request_options =
      options
      |> Map.put(:page, page)
      |> Enum.map(fn {key, value} ->
        "#{key}: #{inspect(value)}"
      end)
      |> Enum.join(", ")

    """
    query {
      #{name}(#{request_options}) {
        docs #{docs}
        hasNextPage
      }
    }
    """
  end

  defp next_page(%__MODULE__{} = paginated) do
    %__MODULE__{paginated | page: paginated.page + 1}
  end
end
