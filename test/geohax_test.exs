defmodule GeohaxTest do
  use ExUnit.Case
  doctest Geohax

  test "should encode coordinates to geohash" do
    assert Geohax.encode(-132.83, -38.1033, 6) == "311x1r"
  end

  test "should decode geohash to coordinates" do
    assert Geohax.decode("311x1r") == {-132.83, -38.1033}
  end

  test "should find geohash neighbors" do
    assert Geohax.neighbors("311x1r") == [north: "311x32", south: "311x1q", east: "311x1x", west: "311x1p"]
  end
end
