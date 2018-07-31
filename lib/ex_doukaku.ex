defmodule ExDoukaku do
  alias ExDoukaku.TestData

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
end
