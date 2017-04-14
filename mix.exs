defmodule Geohax.Mixfile do
  use Mix.Project

  def project do
    [app: :geohax,
     version: "0.2.0",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description,
     package: package,
     deps: deps]
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
    [licenses: ["MIT"],
     maintainers: ["evuez <helloevuez@gmail.com>"],
     links: %{"GitHub" => "https://github.com/evuez/geohax"}]
  end

  def deps do
    [{:ex_doc, ">= 0.0.0", only: :dev},
     {:inch_ex, only: :docs}]
  end
end
