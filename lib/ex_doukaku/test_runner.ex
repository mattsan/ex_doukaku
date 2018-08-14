defmodule ExDoukaku.TestRunner do
  defmacro __using__(opts) do
    quote do
      import ExDoukaku.TestRunner, only: [c_styled_test_data: 1]

      @before_compile ExDoukaku.TestRunner
      @c_styled_test_data []

      case get_in(unquote(opts), [:solver]) do
        nil ->
          @module __MODULE__
          @fun :solve

        [m, f] ->
          @module m
          @fun f

        f ->
          @module __MODULE__
          @fun f
      end

      def run(options \\ []) do
        inspector = Keyword.get(options, :inspector, & &1)

        test_data(options)
        |> test()
        |> Stream.map(inspector)
        |> Enum.to_list()
      end

      def test(test_data) do
        ExDoukaku.test(test_data, @module, @fun)
      end
    end
  end

  defmacro __before_compile__(_) do
    quote do
      def test_data(options \\ []) when is_list(options) do
        src =
          case Keyword.get(options, :data_source, :c_styled_test_data) do
            :c_styled_test_data ->
              @c_styled_test_data

            [json_file: filename] ->
              with {:ok, data} <- ExDoukaku.Data.load_json(filename),
                   do: data.test_data
          end

        case Keyword.get(options, :numbers, []) do
          [] -> src
          numbers -> src |> Enum.filter(&(&1.number in numbers))
        end
      end
    end
  end

  defmacro c_styled_test_data(text) do
    quote do
      @c_styled_test_data ExDoukaku.TestData.CStyled.parse(unquote(text))
    end
  end
end
