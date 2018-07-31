defmodule ExDoukaku.Data do
  defstruct [:event_id, :event_url, :test_data]

  alias ExDoukaku.{Data, TestData}

  def load_json(filename) do
    with {:ok, content} <- File.read(filename),
         {:ok, json} <- Poison.decode(content, as: %Data{test_data: [%TestData{}]}),
         do: {:ok, json}
  end
end
