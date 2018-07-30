defmodule Mix.Tasks.Doukaku.New.OptionParser do
  @moduledoc false

  @options [
    module: :string
  ]

  @aliases [
    m: :module
  ]

  def parse(args) do
    case OptionParser.parse(args, strict: @options, aliases: @aliases) do
      {options, [], []} ->
        {:ok, options}

      {_, args, invalid} ->
        invalid_arguments = Enum.join(Enum.map(invalid, &elem(&1, 0)) ++ args, "','")
        {:error, message: "invalid arguments '#{invalid_arguments}'"}
    end
  end
end
