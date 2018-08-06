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
    |> Stream.map(&elem(&1, 1))
  end

  def test(%TestData{src: src, expected: expected} = test_data, module, fun) do
    actual = apply(module, fun, [src])
    %{test_data: test_data, actual: actual, passed: actual == expected}
  end

  import IO.ANSI, only: [format: 1]

  @passed_format "~4b: #{format([:green, "passed", :reset])}~n"
  @failed_format "~4b: #{format([:red, "failed", :reset, "  input: ~s  expected: ~s,  actual: ~s"])}~n"

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
