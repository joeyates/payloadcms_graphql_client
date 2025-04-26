defmodule PayloadcmsGraphqlClient.MixProject do
  use Mix.Project

  def project do
    [
      app: :payloadcms_graphql_client,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:req, ">= 0.0.0"}
    ]
  end
end
