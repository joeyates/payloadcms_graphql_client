defmodule PayloadcmsGraphqlClient.Client do
  @moduledoc """
  Implements HTTP calls to a GraphQL API.
  """

  alias PayloadcmsGraphqlClient.Query

  def fetch!(%Query{} = query) do
    query_string = to_string(query)

    Req.post!(
      query.endpoint,
      json: %{query: query_string},
      headers: [{"Content-Type", "application/json"}],
      decode_json: [keys: :atoms]
    )
  end
end
