defmodule UriQuery.Mixfile do
  use Mix.Project

  def project do
    [app: :uri_query,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     description: description(),
     package: package()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: []]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:ex_doc, ">= 0.0.0", only: :dev}]
  end

  defp description do
    """
    URI encode nested GET parameters and array values in Elixir.
    """
  end

  defp package do
    [maintainers: ["Oleksandr Avoyants"],
     licenses: ["Apache 2.0"],
     links: %{"GitHub" => "https://github.com/shhavel/uri_query"},
     files: ~w(mix.exs README.md lib)]
  end
end
