defmodule DoukakuTest do
  use ExUnit.Case
  doctest Doukaku

  test "greets the world" do
    assert Doukaku.hello() == :world
  end
end
