defmodule ChatDbEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :chat_db_ex,
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
      mod: {ChatDbEx.Application, []}
    ]
  end

  defp deps do
    [
      {:sqlitex, "~> 1.7"},
      {:jason, "~> 1.0"},
      {:dark_dev, ">= 1.0.3", only: [:dev, :test], runtime: false}
    ]
  end
end
