defmodule Geohax do
  @moduledoc """
  Geohash encoding and decoding.
  """

  import Integer, only: [is_even: 1]
  use Bitwise

  @base32 '0123456789bcdefghjkmnpqrstuvwxyz'

  @lon_range {-180, 180}
  @lat_range {-90, 90}

  @neighbors [
    north: {'p0r21436x8zb9dcf5h7kjnmqesgutwvy', 'bc01fg45238967deuvhjyznpkmstqrwx'},
    south: {'14365h7k9dcfesgujnmqp0r2twvyx8zb', '238967debc01fg45kmstqrwxuvhjyznp'},
    east:  {'bc01fg45238967deuvhjyznpkmstqrwx', 'p0r21436x8zb9dcf5h7kjnmqesgutwvy'},
    west:  {'238967debc01fg45kmstqrwxuvhjyznp', '14365h7k9dcfesgujnmqp0r2twvyx8zb'}
  ]
  @borders [
    north: {"prxz", "bcfguvyz"},
    south: {"028b", "0145hjnp"},
    east:  {"bcfguvyz", "prxz"},
    west:  {"0145hjnp", "028b"}
  ]

  # API

  @doc """
  Encodes a position `{longitude, latitude}` to a Geohash of `precision`
  length.

  ## Example

      iex> Geohax.encode(-132.83, -38.1033, 6)
      "311x1r"
  """
  @spec encode(float, float, pos_integer) :: String.t
  def encode(longitude, latitude, precision \\ 12) do
    bencode(longitude, latitude, precision * 5) |> to_base32
  end

  @doc """
  Decodes a Geohash to a position `{longitude, latitude}`.

  ## Example

      iex> Geohax.decode("311x1r")
      {-132.83, -38.1033}
  """
  @spec decode(String.t) :: {float, float}
  def decode(geohash) do
    geohash
     |> to_base10
     |> to_bits
     |> bdecode
  end

  @doc """
  Find neighbors of a Geohash.

  ## Example

      iex> Geohax.neighbors("311x1r")
      [north: "311x32", south: "311x1q", east: "311x1x", west: "311x1p"]
  """
  @spec neighbors(String.t) :: [{atom, String.t}]
  def neighbors(geohash) do
    [north: neighbor(geohash, :north),
     south: neighbor(geohash, :south),
     east:  neighbor(geohash, :east),
     west:  neighbor(geohash, :west)]
  end

  @doc """
  Find neighbor of a Geohash in a given direction.

  Allowed directions are `:north`, `:south`, `:east` and `:west`.

  ## Example

      iex> Geohax.neighbor("311x1r", :north)
      "311x32"
  """
  # Function taken from http://www.movable-type.co.uk/scripts/geohash.html
  # This is for now just a pale copy of the aforementioned JavaScript
  # function and should be rewritten in a more Elixir-ish way.
  @spec neighbor(String.t, atom) :: String.t
  def neighbor(geohash, direction) do
    last = String.last(geohash)
    type = rem(String.length(geohash), 2)
    base = String.slice(geohash, 0..-2)
    <<last_bits::size(8)>> = last

    if String.contains?(elem(@borders[direction], type), last) do
      base = neighbor(base, direction)
    end

    base <> <<(Enum.at(@base32, Enum.find_index(
       elem(@neighbors[direction], type),
       fn(c) -> c == last_bits end
    )))::size(8)>>
  end

  # Core

  ## Encoding

  defp bencode(lon, lat, size) do
    blon = encode_partial(lon, size - 1, @lon_range)
    blat = encode_partial(lat, size - 2, @lat_range)
    <<(blon + blat)::size(size)>>
  end

  defp encode_partial(_value, size, _range) when size < 0, do: 0
  defp encode_partial(value, size, {min, max}) do
    middle = avg(min, max)

    cond do
      value < middle    -> encode_partial(value, size - 2, {min, middle})
      true -> exp2(size) + encode_partial(value, size - 2, {middle, max})
    end
  end

  ## Decoding

  defp bdecode(hash) do
    {lon_bits, lat_bits} = hash
      |> Enum.with_index
      |> Enum.partition(fn({_, i}) -> is_even(i) end)

    lon = decode_partial(lon_bits, @lon_range)
    lat = decode_partial(lat_bits, @lat_range)

    {lon, lat}
  end

  defp decode_partial([], {min, max}), do: avg(min, max) |> to_fixed({min, max})
  defp decode_partial([{bit, _} | bits], {min, max}) do
    middle = avg(min, max)

    cond do
      bit == 0 -> decode_partial(bits, {min, middle})
      bit == 1 -> decode_partial(bits, {middle, max})
    end
  end

  # Helpers

  defp exp2(n), do: :math.pow(2, n) |> round
  defp avg(x, y), do: (x + y) / 2

  defp to_base32(n), do: (for << i::size(5) <- n >>, do: Enum.fetch!(@base32, i)) |> to_string
  defp to_base10(""), do: []
  defp to_base10(<<char::size(8)>> <> str) do
    [Enum.find_index(@base32, fn(c) -> c == char end) | to_base10(str)]
  end
  defp to_bits([]), do: []
  defp to_bits([n | tail]) do
    Enum.map(4..0, &bit_at(n, &1)) ++ to_bits(tail)
  end

  defp bit_at(bits, index), do: ((1 <<< index) &&& bits) >>> index

  # Format the given coordinate to a fixed-point notation.
  # Function taken from http://www.movable-type.co.uk/scripts/geohash.html
  defp to_fixed(coord, {min, max}) do
    precision = round(Float.floor(2 - :math.log10(max - min)))
    Float.round(coord, precision)
  end
end
