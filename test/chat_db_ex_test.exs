defmodule ChatDbExTest do
  use ExUnit.Case
  doctest ChatDbEx

  test "greets the world" do
    assert ChatDbEx.hello() == :world
  end
end
