defmodule PayloadcmsGraphqlClient.MixProject do
  use Mix.Project

  def project do
    [
      app: :payloadcms_graphql_client,
      version: "0.1.9",
      elixir: "~> 1.17",
      deps: deps(),
      description: "Call the PayloadCMS GraphQL API",
      package: package(),
      start_permanent: Mix.env() == :prod
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:req, ">= 0.0.0"}
    ]
  end

  defp package do
    %{
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/joeyates/payloadcms_graphql_client"
      },
      maintainers: ["Joe Yates"]
    }
  end
end
