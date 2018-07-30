defmodule Mix.Tasks.Doukaku.Test.OptionParser do
  @moduledoc false

  @options [
    runner: :string,
    numbers: :string
  ]

  @aliases [
    r: :runner,
    n: :numbers
  ]

  def parse(args) do
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
end
