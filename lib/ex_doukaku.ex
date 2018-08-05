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

  def test(%TestData{number: number, src: src} = test_data, module, fun) do
    result = apply(module, fun, [src])

    {judgement, message} = judge(test_data, result)

    IO.puts(String.pad_leading(to_string(number), 4, " ") <> ": " <> message)

    [test_data: test_data, result: result, judgement: judgement, message: message]
  end

  embed_text(:passed, to_string(IO.ANSI.format([:green, "passed", :reset])))
  embed_template(:failed, to_string(IO.ANSI.format([:red, "failed", :reset, "  input: '<%= @src %>'  expected: '<%= @expected %>'  actual: '<%= @actual %>'"])))

  defp judge(%TestData{src: src, expected: expected}, result) do
    case result do
      ^expected ->
        {:passed, passed_text()}

      actual ->
        {:failed, failed_template(src: src, expected: expected, actual: actual)}
    end
  end
end
