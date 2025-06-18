defmodule PayloadcmsGraphqlClient do
  @moduledoc """
  This module defines a GraphQL client for the PayloadCMS.
  """

  alias PayloadcmsGraphqlClient.Client
  alias PayloadcmsGraphqlClient.PaginatedQuery
  alias PayloadcmsGraphqlClient.Query

  @doc """
  Fetch the given fields ('docs') of all instances through a given named query.
  """
  def query_all_docs(name, docs, options \\ []) when is_atom(name) do
    Application.ensure_all_started(:req)
    options = Enum.into(options, %{})
    endpoint = Application.fetch_env!(:payloadcms_graphql_client, :endpoint)

    query = %Query{
      endpoint: endpoint,
      name: name,
      docs: docs,
      fields: "hasNextPage",
      options: options
    }

    paginated = %PaginatedQuery{query: query, page: 1}

    PaginatedQuery.fetch(paginated)
  end

  @doc """
  Fetch the given fields ('docs') of a single instance through a given named query.
  """
  def query_one_doc(name, docs, options \\ []) when is_atom(name) do
    Application.ensure_all_started(:req)

    options =
      options
      |> Enum.into(%{})
      |> Map.put(:limit, 1)

    endpoint = Application.fetch_env!(:payloadcms_graphql_client, :endpoint)

    query = %Query{
      endpoint: endpoint,
      name: name,
      docs: docs,
      options: options
    }

    query
    |> Client.fetch!()
    |> handle_one_doc_query(name)
  end

  defp handle_one_doc_query(%Req.Response{status: 200, body: %{errors: errors}}, _name) do
    {:error, inspect(errors)}
  end

  defp handle_one_doc_query(%Req.Response{status: 200, body: body}, name) do
    body
    |> get_in([:data, name, :docs])
    |> hd()
    |> then(&{:ok, &1})
  end
end
