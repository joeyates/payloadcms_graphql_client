defmodule PayloadcmsGraphqlClient do
  @moduledoc """
  This module defines a GraphQL client for the PayloadCMS.
  """

  alias PayloadcmsGraphqlClient.PaginatedQuery

  @doc """
  Fetch the given fields ('docs') of all instances through a given named query.
  """
  def query_all(name, docs, options \\ []) when is_atom(name) do
    Application.ensure_all_started(:req)
    options = Enum.into(options, %{})
    endpoint = Application.fetch_env!(:payloadcms_graphql_client, :endpoint)

    paginated = %PaginatedQuery{
      name: name,
      docs: docs,
      options: options,
      page: 1,
      endpoint: endpoint
    }

    PaginatedQuery.fetch(paginated)
  end
end
