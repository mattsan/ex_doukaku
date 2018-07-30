defmodule ExDoukaku.TestData do
  defstruct [:number, :src, :expected]

  def new do
    %ExDoukaku.TestData{}
  end

  def new(number, src, expected) do
    %ExDoukaku.TestData{number: number, src: src, expected: expected}
  end
end
