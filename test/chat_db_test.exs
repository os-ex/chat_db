defmodule ChatDbTest do
  use ExUnit.Case
  doctest ChatDb

  test "greets the world" do
    assert ChatDb.hello() == :world
  end
end
