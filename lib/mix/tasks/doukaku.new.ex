defmodule Mix.Tasks.Doukaku.New do
  use Mix.Task

  import Mix.Generator, only: [embed_template: 2]

  @shortdoc "generate `doukaku` solver file and test runner file"

  embed_template(:test_runner, ~S'''
    defmodule <%= @module_name %>.TestRunner do
      use ExDoukaku.TestRunner, solver: [<%= @module_name %>.Solver, :solve]

      @data """
        /* 0 */ test("abc", "abc");
      """
    end
    ''')

  embed_template(:solver, ~S"""
    defmodule <%= @module_name %>.Solver do
      def solve(input) do
        input
      end
    end
    """)

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

  defp file_body(module_name, :test_runner), do: test_runner_template(module_name: module_name)
  defp file_body(module_name, :solver), do: solver_template(module_name: module_name)
end
