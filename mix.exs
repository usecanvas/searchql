defmodule SearchQL.Mixfile do
  use Mix.Project

  @version "2.0.0"
  @github_url "https://github.com/usecanvas/searchql"

  def project do
    [app: :searchql,
     description: "A natural-ish language query parser",
     package: package,
     docs: docs,
     source_url: @github_url,
     homepage_url: @github_url,
     version: @version,
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     aliases: aliases,
     dialyzer: [plt_add_apps: [:dialyxir, :mix]]]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
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
    [{:ex_doc, "> 0.0.0", only: [:dev]},
     {:dialyxir, "~> 0.4", only: [:dev, :test], runtime: false},
     {:credo, "~> 0.5", only: [:dev, :test]}]
  end

  defp aliases do
    [ci: ["test", "credo --strict", "dialyzer --halt-exit-status"]]
  end

  defp package do
    [maintainers: ["Jonathan Clem <jonathan@usecanvas.com>"],
     licenses: ["MIT"],
     links: %{GitHub: @github_url},
     files: ~w(lib mix.exs LICENSE.md README.md)]
  end

  defp docs do
    [source_ref: "v#{@version}",
     main: "readme",
     extras: ~w(README.md LICENSE.md)]
  end
end
