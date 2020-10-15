defmodule ChatDB.MixProject do
  use Mix.Project

  def project do
    [
      app: :chat_db,
      version: "1.0.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      dialyzer: [
        ignore_warnings: ".dialyzer_ignore.exs",
        list_unused_filters: true
      ],
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {ChatDB.Application, []}
    ]
  end

  defp deps do
    [
      {:prop_schema, "~> 1.0"},
      {:sqlitex, "~> 1.7"},
      {:jason, "~> 1.0"},
      {:dark_ecto, "~> 1.0"},

      # Development
      {:faker, "~> 0.13", only: [:dev, :test]},
      {:ex_machina, "~> 2.4", only: [:dev, :test]},
      {:dark_dev, ">= 1.0.3", only: [:dev, :test], runtime: false}
    ]
  end
end
