defmodule ExDoukaku.TestData do
  defstruct [:number, :src, :expected]

  alias ExDoukaku.TestData

  def new do
    %TestData{}
  end

  def new(number, src, expected) do
    %TestData{number: number, src: src, expected: expected}
  end
end
