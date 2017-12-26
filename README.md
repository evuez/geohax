# Geohax

[![Hex.pm](https://img.shields.io/hexpm/v/geohax.svg)](https://hex.pm/packages/geohax)
[![Build Status](https://travis-ci.org/evuez/geohax.svg?branch=master)](https://travis-ci.org/evuez/geohax)
[![Inline docs](http://inch-ci.org/github/evuez/geohax.svg)](http://inch-ci.org/github/evuez/geohax)
[![Hex.pm](https://img.shields.io/hexpm/dt/geohax.svg)](https://hex.pm/packages/geohax)
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fevuez%2Fgeohax.svg?type=shield)](https://app.fossa.io/projects/git%2Bgithub.com%2Fevuez%2Fgeohax?ref=badge_shield)

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

### Calculating geoashes within an envelope

```elixir
iex> Geohax.within([52.291725, 16.731831, 52.508736, 17.071703])
["u37ck", "u37cm", "u37cq", "u37cr", "u3k12", "u3k13", "u3k16", "u3k17", "u3k1k", "u37cs", "u37ct", "u37cw", "u37cx", "u3k18", "u3k19", "u3k1d", "u3k1e", "u3k1s", "u37cu", "u37cv", "u37cy", "u37cz", "u3k1b", "u3k1c", "u3k1f", "u3k1g", "u3k1u", "u37fh", "u37fj", "u37fn", "u37fp", "u3k40", "u3k41", "u3k44", "u3k45", "u3k4h", "u37fk", "u37fm", "u37fq", "u37fr", "u3k42", "u3k43", "u3k46", "u3k47", "u3k4k", "u37fs", "u37ft", "u37fw", "u37fx", "u3k48", "u3k49", "u3k4d", "u3k4e", "u3k4s"]
```

## Installation

Add the `:geohax` dependency to your `mix.exs` file:

```elixir
defp deps do
  [{:geohax, ">= 0.0.0"}]
end
```

Then, run `mix deps.get` to fetch the new dependency.


## License
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fevuez%2Fgeohax.svg?type=large)](https://app.fossa.io/projects/git%2Bgithub.com%2Fevuez%2Fgeohax?ref=badge_large)