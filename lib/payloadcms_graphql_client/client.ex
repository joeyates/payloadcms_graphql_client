defmodule PayloadcmsGraphqlClient.Client do
  @moduledoc """
  Implements HTTP calls to a GraphQL API.
  """

  alias PayloadcmsGraphqlClient.Query

  def fetch!(%Query{} = query) do
    query_string = to_string(query)
    timeout = Application.get_env(:payloadcms_graphql_client, :timeout, 30_000)
    headers = headers()

    Req.post!(
      query.endpoint,
      json: %{query: query_string},
      headers: headers,
      connect_options: [timeout: timeout],
      decode_json: [keys: :atoms]
    )
  end

  defp headers() do
    headers = [
      {"Content-Type", "application/json"}
    ]

    headers ++ autorization_header() ++ extra_headers()
  end

  defp autorization_header() do
    case api_key_value() do
      nil -> []
      value -> [{"Authorization", value}]
    end
  end

  defp extra_headers() do
    Application.get_env(:payloadcms_graphql_client, :extra_headers, [])
  end

  defp api_key_value() do
    case api_key() do
      nil ->
        nil

      api_key ->
        collection_slug =
          Application.get_env(:payloadcms_graphql_client, :api_key_collection_slug, "users")

        "#{collection_slug} API-Key #{api_key}"
    end
  end

  defp api_key() do
    Application.get_env(:payloadcms_graphql_client, :api_key)
  end
end
