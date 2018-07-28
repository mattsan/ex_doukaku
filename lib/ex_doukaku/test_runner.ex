defmodule ExDoukaku.TestRunner do
  use Supervisor

  defmacro __using__(opts) do
    [module, fun] = get_in(opts, [:solver])

    quote do
      @before_compile ExDoukaku.TestRunner

      def run(options \\ []) do
        case options[:numbers] do
          [] ->
            test(data())

          numbers ->
            data()
            |> Enum.filter(&(&1.number in numbers))
            |> test()
        end
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
      @test_pattern ~r{/\*\s*(\d+)\s*\*/\s*test\s*\(\s*"([^"]+)"\s*,\s*"([^"]+)"\s*\)}
      @test_data @data
                 |> String.split("\n", trim: true)
                 |> Enum.map(&Regex.run(@test_pattern, &1))
                 |> Enum.map(fn [_, number, src, expected] ->
                   %{number: String.to_integer(number), src: src, expected: expected}
                 end)

      def data do
        @test_data
      end
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

  def test(%{number: number, src: src, expected: expected}, module, fun) do
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

  def init(_) do
    children = [
      {Task.Supervisor, name: ExDoukaku.TaskSupervisor}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
