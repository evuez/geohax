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

  test "should return all the geohashes within an envelope" do
    assert Geohax.within({16.731831, 52.291725, 17.071703, 52.508736}) ==
      ["u37ck", "u37cm", "u37cq", "u37cr", "u3k12", "u3k13", "u3k16", "u3k17", "u3k1k",
       "u37cs", "u37ct", "u37cw", "u37cx", "u3k18", "u3k19", "u3k1d", "u3k1e", "u3k1s",
       "u37cu", "u37cv", "u37cy", "u37cz", "u3k1b", "u3k1c", "u3k1f", "u3k1g", "u3k1u",
       "u37fh", "u37fj", "u37fn", "u37fp", "u3k40", "u3k41", "u3k44", "u3k45", "u3k4h",
       "u37fk", "u37fm", "u37fq", "u37fr", "u3k42", "u3k43", "u3k46", "u3k47", "u3k4k",
       "u37fs", "u37ft", "u37fw", "u37fx", "u3k48", "u3k49", "u3k4d", "u3k4e", "u3k4s"]
  end

  test "should return all the geohashes within an envelope with given precision" do
    assert Geohax.within({16.731831, 52.291725, 17.071703, 52.508736}, 3) == ["u37", "u3k"]
  end
end
