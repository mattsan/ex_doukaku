defmodule ExDoukaku.TestData do
  defstruct [:number, :src, :expected]

  alias ExDoukaku.TestData

  def new do
    %TestData{}
  end

  def new(number, src, expected) do
    %TestData{number: number, src: src, expected: expected}
  end

  defmodule CStyled do
    @test_pattern ~r{/\*\s*(?<number>\d+)\s*\*/\s*test\s*\(\s*"(?<src>[^"]+)"\s*,\s*"(?<expected>[^"]+)"\s*\)}

    def parse(text) do
      text
      |> String.split("\n", trim: true)
      |> Enum.map(&Regex.named_captures(@test_pattern, &1))
      |> Enum.map(&TestData.new(String.to_integer(&1["number"]), &1["src"], &1["expected"]))
    end
  end
end
