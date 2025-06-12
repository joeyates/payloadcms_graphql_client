defmodule PayloadcmsGraphqlClient.PaginatedQuery do
  alias PayloadcmsGraphqlClient.Client
  alias PayloadcmsGraphqlClient.Query

  @enforce_keys [:query]
  defstruct [:query, page: 1]

  @type t :: %__MODULE__{
          query: Query.t(),
          page: integer()
        }

  def fetch(%__MODULE__{} = paginated) do
    paginated
    |> to_query()
    |> Client.fetch!()
    |> handle_response(paginated)
  end

  defp handle_response(%Req.Response{status: 200, body: body}, paginated) do
    has_next_page = get_in(body, [:data, paginated.query.name, :hasNextPage])
    results = get_in(body, [:data, paginated.query.name, :docs])

    if has_next_page do
      paginated = next_page(paginated)
      results ++ fetch(paginated)
    else
      results
    end
  end

  defp to_query(%__MODULE__{} = paginated) do
    options = Map.put(paginated.query.options, :page, paginated.page)
    %{paginated.query | options: options}
  end

  defp next_page(%__MODULE__{} = paginated) do
    %{paginated | page: paginated.page + 1}
  end
end
