defmodule Mix.Tasks.Doukaku.Test do
  use Mix.Task

  alias Mix.Tasks.Doukaku.Test

  @shortdoc "run `doukaku` tests"

  @test_runner_module_name "TestRunner"

  def run(args) do
    {time, result} =
      :timer.tc(fn ->
        with {:ok, options} <- Test.OptionParser.parse(args),
             {:ok, runner_module} <- get_runner_module(options),
             do: run_test(runner_module, options)
      end)

    case result do
      {:ok, _} ->
        :ok

      {:error, message: message} ->
        Mix.Shell.IO.error(message)
    end

    Mix.Shell.IO.info("\n#{ExUnit.Formatter.format_time(time, nil)}\n")
  end

  defp setup(config) do
    Mix.Project.get!()
    Mix.Project.compile([], config)
    Application.start(:poison)
    Application.start(:ex_doukaku)
    Application.start(config[:app])
  end

  defp get_runner_module(options) do
    config = Mix.Project.config()

    setup(config)

    runner_module =
      case options[:runner] do
        nil ->
          Application.spec(config[:app], :modules)
          |> Enum.find(&(List.last(Module.split(&1)) == @test_runner_module_name))

        runner_name ->
          Module.concat([runner_name])
      end

    {:ok, runner_module}
  end

  defp run_test(runner_module, options) do
    try do
      options = put_in(options[:inspector], &ExDoukaku.inspect_result/1)

      options =
        case pop_in(options[:json_file]) do
          {nil, _} ->
            options

          {filename, next_options} ->
            put_in(next_options[:data_source], json_file: filename)
        end

      {:ok, apply(runner_module, :run, [options])}
    rescue
      e in [UndefinedFunctionError] ->
        {:error, message: "#{inspect(e.module)} don't  have #{e.function}/#{e.arity}"}
    end
  end
end
