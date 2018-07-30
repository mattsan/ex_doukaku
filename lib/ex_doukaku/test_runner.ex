defmodule ExDoukaku.TestRunner do
  use Supervisor

  alias ExDoukaku.TestData

  defmacro __using__(opts) do
    [module, fun] = get_in(opts, [:solver])

    quote do
      @before_compile ExDoukaku.TestRunner
      import ExDoukaku.TestRunner, only: [test_data: 1]

      @data []

      def run(options \\ []) do
        numbers = Keyword.get(options, :numbers, [])

        test_data =
          case numbers do
            [] -> data()
            numbers -> data() |> Enum.filter(&(&1.number in numbers))
          end

        test(test_data)
      end

      def test(test_data) do
        test_data
        |> ExDoukaku.TestRunner.test(unquote(module), unquote(fun))
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

  defmacro test_data(text) do
    quote do
      @test_pattern ~r{/\*\s*(?<number>\d+)\s*\*/\s*test\s*\(\s*"(?<src>[^"]+)"\s*,\s*"(?<expected>[^"]+)"\s*\)}

      @data unquote(text)
            |> String.split("\n", trim: true)
            |> Enum.map(&Regex.named_captures(@test_pattern, &1))
            |> Enum.map(&TestData.new(String.to_integer(&1["number"]), &1["src"], &1["expected"]))
    end
  end

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def test(test_data, module, fun) when is_list(test_data) do
    opts = [ordered: false, timeout: :infinity]

    Task.Supervisor.async_stream(
      ExDoukaku.TaskSupervisor,
      test_data,
      __MODULE__,
      :test,
      [module, fun],
      opts
    )
    |> Enum.map(&elem(&1, 1))
  end

  def test(%TestData{number: number, src: src, expected: expected}, module, fun) do
    result = apply(module, fun, [src])

    view =
      case result do
        ^expected ->
          IO.ANSI.format([:green, "passed", :reset])

        actual ->
          IO.ANSI.format([
            :red,
            "failed",
            :reset,
            "  input: '#{src}'  expected: '#{expected}'  actual: '#{actual}'"
          ])
      end

    :io.format("~4b: ~s~n", [number, view])
    {number, result}
  end

  @doc false
  def init(_) do
    children = [
      {Task.Supervisor, name: ExDoukaku.TaskSupervisor}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
