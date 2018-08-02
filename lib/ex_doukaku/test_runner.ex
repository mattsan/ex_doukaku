defmodule ExDoukaku.TestRunner do
  defmacro __using__(opts) do
    [module, fun] = get_in(opts, [:solver])

    quote do
      @before_compile ExDoukaku.TestRunner
      import ExDoukaku.TestRunner, only: [c_styled_test_data: 1]

      @c_styled_test_data []

      def run(options \\ []) do
        numbers = Keyword.get(options, :numbers, [])
        data_source = Keyword.get(options, :data_source, :c_styled_test_data)

        test_data(data_source, numbers)
        |> test()
        |> Enum.to_list()
      end

      def test(test_data) do
        ExDoukaku.test(test_data, unquote(module), unquote(fun))
      end
    end
  end

  defmacro __before_compile__(_) do
    quote do
      def test_data(data_source, nil), do: test_data(data_source)
      def test_data(data_source, []), do: test_data(data_source)

      def test_data(data_source, numbers) do
        test_data(data_source)
        |> Enum.filter(&(&1.number in numbers))
      end

      def test_data(:c_styled_test_data), do: @c_styled_test_data

      def test_data(json_file: filename) do
        with {:ok, data} <- ExDoukaku.Data.load_json(filename),
             do: data.test_data
      end
    end
  end

  defmacro c_styled_test_data(text) do
    quote do
      @c_styled_test_data ExDoukaku.TestData.CStyled.parse(unquote(text))
    end
  end
end
