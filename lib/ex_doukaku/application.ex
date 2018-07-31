defmodule ExDoukaku.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: ExDoukaku.TaskSupervisor}
    ]

    opts = [strategy: :one_for_one, name: ExDoukaku.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
