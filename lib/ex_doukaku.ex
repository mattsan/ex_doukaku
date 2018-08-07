defmodule ExDoukaku do
  alias ExDoukaku.TestData

  import IO.ANSI, only: [format: 1]

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
    |> Stream.map(&elem(&1, 1))
  end

  def test(%TestData{src: src, expected: expected} = test_data, module, fun) do
    try do
      actual = apply(module, fun, [src])
      %{test_data: test_data, actual: actual, passed: actual == expected}
    rescue
      e ->
        stacktrace =
          System.stacktrace()
          |> Enum.take_while(&(elem(&1, 0) != ExDoukaku))
          |> Exception.format_stacktrace()
          |> String.split("\n", trim: true)
          |> Enum.map(&"          #{&1}")
          |> Enum.join("\n")

        actual =
          format([:red, "(", inspect(e.__struct__), ") ", Exception.message(e), "\n", stacktrace])

        %{test_data: test_data, actual: actual, passed: false}
    end
  end

  @passed_format format(["~4b: ", :green, "passed", :reset, "~n"]) |> to_string()
  @failed_format format([
                   "~4b: ",
                   :red,
                   "failed",
                   :reset,
                   "  input: ~s  expected: ~s,  actual: ~s~n"
                 ])
                 |> to_string()

  def inspect_result(%{} = result) do
    case result.passed do
      true ->
        :io.format(@passed_format, [result.test_data.number])

      false ->
        :io.format(@failed_format, [
          result.test_data.number,
          result.test_data.src,
          result.test_data.expected,
          result.actual
        ])
    end
  end
end
