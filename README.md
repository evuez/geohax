# Geohax

[![Hex.pm](https://img.shields.io/hexpm/v/geohax.svg)](https://hex.pm/packages/geohax)
[![Build Status](https://travis-ci.org/evuez/geohax.svg?branch=master)](https://travis-ci.org/evuez/geohax)
[![Inline docs](http://inch-ci.org/github/evuez/geohax.svg)](http://inch-ci.org/github/evuez/geohax)
[![Hex.pm](https://img.shields.io/hexpm/dt/geohax.svg)](https://hex.pm/packages/geohax)

Geohash encoding and decoding for Elixir.

## Usage

### Encoding and decoding

```elixir
iex> Geohax.encode(-132.83, -38.1033, 6)
"311x1r"
iex> Geohax.decode("311x1r")
{-132.83, -38.1033}
```

Note that the format for coordinates is `{longitude, latitude}`.

### Finding neighbors

```elixir
iex> Geohax.neighbors("311x1r")
[north: "311x32", south: "311x1q", east: "311x1x", west: "311x1p"]
iex> Geohax.neighbor("311x1r", :north)
"311x32"
```

## Installation

Add the `:geohax` dependency to your `mix.exs` file:

```elixir
defp deps do
  [{:geohax, ">= 0.0.0"}]
end
```

Then, run `mix deps.get` to fetch the new dependency.
