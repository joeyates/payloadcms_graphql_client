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

    headers ++ autorization_header()
  end

  defp autorization_header() do
    auth_values = Enum.filter([basic_auth_value(), api_key_value()], & &1)

    case auth_values do
      [] -> []
      values -> [{"Authorization", Enum.join(values, ", ")}]
    end
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

  defp basic_auth_value() do
    case {basic_auth_user(), basic_auth_password()} do
      {nil, _} ->
        nil

      {_, nil} ->
        nil

      {user, password} ->
        encoded = Base.encode64("#{user}:#{password}")
        "Basic #{encoded}"
    end
  end

  defp api_key() do
    Application.get_env(:payloadcms_graphql_client, :api_key)
  end

  defp basic_auth_password() do
    Application.get_env(:payloadcms_graphql_client, :basic_auth_password)
  end

  defp basic_auth_user() do
    Application.get_env(:payloadcms_graphql_client, :basic_auth_user)
  end
end
