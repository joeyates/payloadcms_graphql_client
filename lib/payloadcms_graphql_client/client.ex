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
      headers: headers(),
      connect_options: [timeout: timeout],
      decode_json: [keys: :atoms]
    )
  end

  defp headers() do
    headers = [
      {"Content-Type", "application/json"}
    ]

    api_key = Application.get_env(:payloadcms_graphql_client, :api_key)

    if api_key do
      collection_slug =
        Application.get_env(:payloadcms_graphql_client, :api_key_collection_slug, "users")

      headers ++ [{"Authorization", "#{collection_slug} API-Key #{api_key}"}]
    else
      headers
    end
  end
end
