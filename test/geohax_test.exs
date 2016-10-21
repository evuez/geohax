defmodule GeohaxTest do
  use ExUnit.Case
  doctest Geohax

  test "should encode coordinates to geohash" do
    assert Geohax.encode(-132.83, -38.1033, 6) == "311x1r"
  end

  test "should decode geohash to coordinates" do
    assert Geohax.decode("311x1r") == {-132.83, -38.1033}
  end
end
