defmodule PayloadcmsGraphqlClient.Query do
  @moduledoc """
  A struct defining a GraphQL query.
  """

  @enforce_keys [:endpoint, :name, :docs]
  defstruct [
    :endpoint,
    :name,
    :docs,
    fields: "",
    options: %{}
  ]

  @type t :: %__MODULE__{
          endpoint: String.t(),
          name: atom(),
          docs: String.t(),
          fields: String.t() | nil,
          options: map()
        }

  defimpl String.Chars do
    def to_string(query) do
      request_options = stringify_options(query.options)

      """
      query {
        #{query.name}(#{request_options}) {
          docs #{query.docs}
          #{query.fields}
        }
      }
      """
    end

    defp stringify_options(options) do
      options
      |> Enum.map(fn {key, value} ->
        "#{key}: #{stringify_option(value)}"
      end)
      |> Enum.join(", ")
    end

    def stringify_option(value) when is_binary(value), do: inspect(value)

    def stringify_option(value), do: Kernel.to_string(value)
  end
end
