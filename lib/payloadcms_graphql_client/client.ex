defmodule PayloadcmsGraphqlClient.Client do
  @moduledoc """
  Implements HTTP calls to a GraphQL API.
  """

  alias PayloadcmsGraphqlClient.Query

  def fetch!(%Query{} = query) do
    query_string = to_string(query)
    timeout = Application.get_env(:payloadcms_graphql_client, :timeout, 30_000)

    Req.post!(
      query.endpoint,
      json: %{query: query_string},
      headers: [{"Content-Type", "application/json"}],
      connect_options: [timeout: timeout],
      decode_json: [keys: :atoms]
    )
  end
end
