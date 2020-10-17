defmodule Geohax.Mixfile do
  use Mix.Project

  @source_url "https://github.com/evuez/geohax"

  def project do
    [
      app: :geohax,
      version: "0.4.1",
      elixir: "~> 1.4",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      docs: docs()
    ]
  end

  def application do
    [applications: []]
  end

  defp description do
    """
    Geohash encoding and decoding for Elixir.
    """
  end

  defp package do
    [
      licenses: ["MIT"],
      maintainers: ["evuez <helloevuez@gmail.com>"],
      links: %{"GitHub" => @source_url}
    ]
  end

  def deps do
    [{:ex_doc, ">= 0.0.0", only: :dev}, {:inch_ex, only: :docs}]
  end

  defp docs do
    [main: "Geohax", source_url: @source_url]
  end
end
