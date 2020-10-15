defmodule ChatDBTest do
  use ExUnit.Case
  doctest ChatDB

  test "greets the world" do
    assert ChatDB.hello() == :world
  end
end
