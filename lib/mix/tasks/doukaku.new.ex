defmodule Mix.Tasks.Doukaku.New do
  use Mix.Task

  import Mix.Generator, only: [embed_template: 2, create_file: 2]

  alias Mix.Tasks.Doukaku.New

  @shortdoc "generate `doukaku` solver file and test runner file"

  embed_template(:test_runner, ~S'''
  defmodule <%= @module_name %>.TestRunner do
    use ExDoukaku.TestRunner, solver: [<%= @module_name %>.Solver, :solve]

    c_styled_test_data """
      /* 0 */ test("abc", "abc");
    """
  end
  ''')

  embed_template(:solver, ~S'''
  defmodule <%= @module_name %>.Solver do
    def solve(input) do
      input
    end
  end
  ''')

  def run(args) do
    {:ok, options} = New.OptionParser.parse(args)

    app_name = Mix.Project.config()[:app]

    module_name = Keyword.get(options, :module, app_name |> Atom.to_string() |> Macro.camelize())

    app_name
    |> file_name(:test_runner)
    |> create_file(test_runner_template(module_name: module_name))

    app_name
    |> file_name(:solver)
    |> create_file(solver_template(module_name: module_name))
  end

  defp file_name(app, name), do: "lib/#{app}/#{name}.ex"
end
