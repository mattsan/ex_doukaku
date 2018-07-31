defmodule ExDoukaku.TestRunner do
  alias ExDoukaku.TestData

  defmacro __using__(opts) do
    [module, fun] = get_in(opts, [:solver])

    quote do
      @before_compile ExDoukaku.TestRunner
      import ExDoukaku.TestRunner, only: [c_styled_test_data: 1]

      @data []

      def run(options \\ []) do
        numbers = Keyword.get(options, :numbers, [])

        test_data =
          case numbers do
            [] -> data()
            numbers -> data() |> Enum.filter(&(&1.number in numbers))
          end

        test_data
        |> ExDoukaku.test(unquote(module), unquote(fun))
        |> Enum.to_list()
      end
    end
  end

  defmacro __before_compile__(_) do
    quote do
      def data do
        @data
      end
    end
  end

  defmacro test_pattern do
    quote do
    end
  end

  defmacro c_styled_test_data(text) do
    quote do
      @test_pattern ~r{/\*\s*(?<number>\d+)\s*\*/\s*test\s*\(\s*"(?<src>[^"]+)"\s*,\s*"(?<expected>[^"]+)"\s*\)}

      @data unquote(text)
            |> String.split("\n", trim: true)
            |> Enum.map(&Regex.named_captures(@test_pattern, &1))
            |> Enum.map(&TestData.new(String.to_integer(&1["number"]), &1["src"], &1["expected"]))
    end
  end
end
