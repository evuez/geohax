defmodule Geohax do
  @moduledoc """
  Geohash encoding and decoding.
  """

  use Bitwise

  import Integer, only: [is_even: 1]

  @type longitude() :: float()
  @type latitude() :: float()
  @type direction() :: :north | :south | :east | :west

  @base32 '0123456789bcdefghjkmnpqrstuvwxyz'

  @lon_range {-180, 180}
  @lat_range {-90, 90}

  @neighbors [
    north: {'p0r21436x8zb9dcf5h7kjnmqesgutwvy', 'bc01fg45238967deuvhjyznpkmstqrwx'},
    south: {'14365h7k9dcfesgujnmqp0r2twvyx8zb', '238967debc01fg45kmstqrwxuvhjyznp'},
    east: {'bc01fg45238967deuvhjyznpkmstqrwx', 'p0r21436x8zb9dcf5h7kjnmqesgutwvy'},
    west: {'238967debc01fg45kmstqrwxuvhjyznp', '14365h7k9dcfesgujnmqp0r2twvyx8zb'}
  ]
  @borders [
    north: {'prxz', 'bcfguvyz'},
    south: {'028b', '0145hjnp'},
    east: {'bcfguvyz', 'prxz'},
    west: {'0145hjnp', '028b'}
  ]

  # API

  @doc """
  Encodes a position `{longitude, latitude}` to a Geohash of `precision`
  length.

  ## Example

      iex> Geohax.encode(-132.83, -38.1033, 6)
      "311x1r"
  """
  @spec encode(longitude(), latitude(), pos_integer()) :: String.t()
  def encode(longitude, latitude, precision \\ 12) do
    bencode(longitude, latitude, precision * 5) |> to_base32()
  end

  @doc """
  Decodes a Geohash to a position `{longitude, latitude}`.

  ## Example

      iex> Geohax.decode("311x1r")
      {-132.83, -38.1033}
  """
  @spec decode(String.t()) :: {longitude(), latitude()}
  def decode(geohash) do
    geohash
    |> to_base10()
    |> to_bits()
    |> bdecode()
  end

  @doc """
  Finds neighbors of a Geohash.

  ## Example

      iex> Geohax.neighbors("311x1r")
      %{north: "311x32", south: "311x1q", east: "311x1x", west: "311x1p"}
  """
  @spec neighbors(String.t()) :: %{direction() => String.t()}
  def neighbors(geohash) do
    %{
      north: neighbor(geohash, :north),
      south: neighbor(geohash, :south),
      east: neighbor(geohash, :east),
      west: neighbor(geohash, :west)
    }
  end

  @doc """
  Finds neighbor of a Geohash in a given direction.

  Allowed directions are `:north`, `:south`, `:east` and `:west`.

  ## Example

      iex> Geohax.neighbor("311x1r", :north)
      "311x32"
  """
  @spec neighbor(String.t(), direction()) :: String.t()
  def neighbor(geohash, direction) do
    <<last::size(8)>> = String.last(geohash)
    type = rem(String.length(geohash), 2)
    base = String.slice(geohash, 0..-2)

    if(last in elem(@borders[direction], type), do: neighbor(base, direction), else: base) <>
      <<Enum.fetch!(
          @base32,
          :string.str(
            elem(@neighbors[direction], type),
            [last]
          ) - 1
        )::size(8)>>
  end

  @doc """
  Finds all the Geohashes within `{min_lon, min_lat}, {max_lon, max_lat}` with the
  given `precision`.

  ## Examples

      iex> Geohax.within({16.731831, 52.291725}, {17.071703, 52.508736})
      ["u37ck", "u37cm", "u37cq", "u37cr", "u3k12", "u3k13", "u3k16", "u3k17",
        "u3k1k", "u37cs", "u37ct", "u37cw", "u37cx", "u3k18", "u3k19", "u3k1d",
        "u3k1e", "u3k1s", "u37cu", "u37cv", "u37cy", "u37cz", "u3k1b", "u3k1c",
        "u3k1f", "u3k1g", "u3k1u", "u37fh", "u37fj", "u37fn", "u37fp", "u3k40",
        "u3k41", "u3k44", "u3k45", "u3k4h", "u37fk", "u37fm", "u37fq", "u37fr",
        "u3k42", "u3k43", "u3k46", "u3k47", "u3k4k", "u37fs", "u37ft", "u37fw",
        "u37fx", "u3k48", "u3k49", "u3k4d", "u3k4e", "u3k4s"]

      iex> Geohax.within({16.731831, 52.291725}, {17.071703, 52.508736}, 3)
      ["u37", "u3k"]
  """
  @spec within({longitude(), latitude()}, {longitude(), latitude()}, pos_integer()) :: [String.t()]
  def within({min_lon, min_lat}, {max_lon, max_lat}, precision \\ 5) do
    sw = encode(min_lon, min_lat, precision)
    ne = encode(max_lon, max_lat, precision)
    se = encode(max_lon, min_lat, precision)
    south_border(ne, se, sw)
  end

  # Core

  ## Encoding

  defp bencode(lon, lat, size) do
    blon = encode_partial(lon, size - 1, @lon_range)
    blat = encode_partial(lat, size - 2, @lat_range)
    <<blon + blat::size(size)>>
  end

  defp encode_partial(_value, size, _range) when size < 0, do: 0

  defp encode_partial(value, size, {min, max}) do
    middle = avg(min, max)

    if value < middle,
      do: encode_partial(value, size - 2, {min, middle}),
      else: exp2(size) + encode_partial(value, size - 2, {middle, max})
  end

  ## Decoding

  defp bdecode(hash) do
    {lon_bits, lat_bits} =
      hash
      |> Enum.with_index()
      |> Enum.split_with(fn {_, i} -> is_even(i) end)

    lon = decode_partial(lon_bits, @lon_range)
    lat = decode_partial(lat_bits, @lat_range)

    {lon, lat}
  end

  defp decode_partial([], {min, max}), do: avg(min, max) |> to_fixed({min, max})

  defp decode_partial([{0, _} | bits], {min, max}),
    do: decode_partial(bits, {min, avg(min, max)})

  defp decode_partial([{1, _} | bits], {min, max}),
    do: decode_partial(bits, {avg(min, max), max})

  # Helpers

  defp exp2(n), do: :math.pow(2, n) |> round()
  defp avg(x, y), do: (x + y) / 2

  defp to_base32(n),
    do: for(<<i::size(5) <- n>>, do: Enum.fetch!(@base32, i)) |> to_string()

  defp to_base10(""), do: []

  defp to_base10(<<char::size(8)>> <> str),
    do: [:string.str(@base32, [char]) - 1 | to_base10(str)]

  defp to_bits([]), do: []
  defp to_bits([n | tail]), do: Enum.map(4..0, &bit_at(n, &1)) ++ to_bits(tail)

  defp bit_at(bits, index), do: (1 <<< index &&& bits) >>> index

  # Format the given coordinate to a fixed-point notation.
  defp to_fixed(coord, {min, max}) do
    precision = round(Float.floor(2 - :math.log10(max - min)))
    Float.round(coord, precision)
  end

  defp south_border(ne, se, sw, acc \\ []) do
    if sw in acc,
      do: north_border(ne, acc),
      else: south_border(ne, neighbor(se, :west), sw, [se | acc])
  end

  defp north_border(ne, row, acc \\ []) do
    if ne in row,
      do: acc ++ row,
      else: north_border(ne, Enum.map(row, &neighbor(&1, :north)), acc ++ row)
  end
end
