defmodule Mix.Tasks.Doukaku.Test do
  use Mix.Task

  @shortdoc "run `doukaku` tests"

  @test_runner_module_name "TestRunner"

  def run(args) do
    {time, result} =
      :timer.tc(fn ->
        with {:ok, options} <- parse_options(args),
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

  @options [
    runner: :string,
    numbers: :string
  ]

  @aliases [
    r: :runner,
    n: :numbers
  ]

  defp parse_options(args) do
    with {:ok, options} <- parse_args(args),
         {:ok, numbers} <- parse_numbers(options[:numbers]),
         do: {:ok, Keyword.put(options, :numbers, numbers)}
  end

  defp parse_args(args) do
    case OptionParser.parse(args, strict: @options, aliases: @aliases) do
      {options, [], []} ->
        {:ok, options}

      {_, args, invalid} ->
        invalid_arguments = Enum.join(Enum.map(invalid, &elem(&1, 0)) ++ args, "','")
        {:error, message: "invalid arguments '#{invalid_arguments}'"}
    end
  end

  defp parse_numbers(numbers_string) do
    %{numbers: numbers, errors: errors} =
      case numbers_string do
        nil ->
          %{numbers: [], errors: []}

        _ ->
          numbers_string
          |> String.split(~r{[ ,]+}, trim: true)
          |> Enum.reduce(%{numbers: [], errors: []}, fn s, acc ->
            case Integer.parse(s) do
              {number, ""} ->
                %{acc | numbers: [number | acc.numbers]}

              _ ->
                %{acc | errors: [s | acc.errors]}
            end
          end)
      end

    case errors do
      [] ->
        {:ok, Enum.reverse(numbers)}

      _ ->
        non_integer_values = errors |> Enum.reverse() |> Enum.join("','")
        {:error, message: "non-integer values '#{non_integer_values}'"}
    end
  end

  defp setup(config) do
    Mix.Project.get!()
    Mix.Project.compile([], config)
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
      {:ok, apply(runner_module, :run, [options])}
    rescue
      e in [UndefinedFunctionError] ->
        {:error, message: "#{inspect(e.module)} don't  have #{e.function}/#{e.arity}"}
    end
  end
end
