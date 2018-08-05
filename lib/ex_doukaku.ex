defmodule ExDoukaku do
  alias ExDoukaku.TestData

  import Mix.Generator, only: [embed_template: 2, embed_text: 2]

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


  def test(%TestData{src: src, expected: expected} = test_data, module, fun) do
    actual = apply(module, fun, [src])

    judgement =
      case actual do
        ^expected -> :passed
        _ -> :failed
      end

    result = %{test_data: test_data, actual: actual, judgement: judgement}
    show_result(result)
    result
  end

  embed_text(:passed, to_string(IO.ANSI.format([:green, "passed", :reset])))
  embed_template(:failed, to_string(IO.ANSI.format([:red, "failed", :reset, "  input: '<%= @src %>'  expected: '<%= @expected %>'  actual: '<%= @actual %>'"])))

  def show_result(%{test_data: %TestData{number: number, expected: expected}, actual: expected, judgement: :passed}) do
    IO.puts(String.pad_leading(to_string(number), 4, " ") <> ": " <> passed_text())
  end

  def show_result(%{test_data: %TestData{number: number, src: src, expected: expected}, actual: actual, judgement: :failed}) do
    IO.puts(String.pad_leading(to_string(number), 4, " ") <> ": " <> failed_template(src: src, expected: expected, actual: actual))
  end
end
