# Geohax

[![Build Status](https://travis-ci.org/evuez/geohax.svg?branch=master)](https://travis-ci.org/evuez/geohax)

Geohash encoding and decoding for Elixir.

## Usage

```elixir
iex> Geohax.encode(-132.83, -38.1033, 6)
"311x1r"
iex> Geohax.decode("311x1r")
{-132.83, -38.1033}
```

Note that the format for coordinates is `{longitude, latitude}`.

## Installation

Add the `:geohax` dependency to your `mix.exs` file:

```elixir
defp deps do
  [{:geohax, ">= 0.0.0"}]
end
```

Then, run `mix deps.get` to fetch the new dependency.
