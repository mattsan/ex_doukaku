defmodule Mix.Tasks.Doukaku.New do
  use Mix.Task

  @options [module: :string]
  @aliases [m: :module]

  def run(args) do
    {options, [], []} = OptionParser.parse(args, strict: @options, aliases: @aliases)

    app_name = Mix.Project.config()[:app]

    module_name =
      case options[:module] do
        nil -> app_name |> Atom.to_string() |> Macro.camelize()
        module_name -> module_name
      end

    create_file(app_name, module_name, :test_runner)
    create_file(app_name, module_name, :solver)
  end

  defp create_file(app_name, module_name, target_name) do
    app_name
    |> file_name(target_name)
    |> Mix.Generator.create_file(file_body(module_name, target_name))
  end

  defp file_name(app, name), do: "lib/#{app}/#{name}.ex"

  defp file_body(module_name, :test_runner) do
    """
    defmodule #{module_name}.TestRunner do
      use ExDoukaku.TestRunner, solver: [#{module_name}.Solver, :solve]

      @data \"\"\"
        /* 0 */ test("abc", "abc");
      \"\"\"
    end
    """
  end

  defp file_body(module_name, :solver) do
    """
    defmodule #{module_name}.Solver do
      def solve(input) do
        input
      end
    end
    """
  end
end
