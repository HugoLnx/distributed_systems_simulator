defmodule SimulationSupervisor do
  use Supervisor, restart: :temporary

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts)
  end

  def init(%{storage_supervisor_spec: storage_supervisor_spec, worker_router: router, writers: writers, readers: readers}) do
    children = [
      storage_supervisor_spec,
      Supervisor.child_spec(
        {WorkersSupervisor, %{worker_module: WriterNode, amount: writers, worker_router: router}},
        id: :writers_supervisor
      ),
      Supervisor.child_spec(
        {WorkersSupervisor, %{worker_module: ReaderNode, amount: readers, worker_router: router}},
        id: :readers_supervisor
      )
    ]
    Supervisor.init(children, strategy: :one_for_all)
  end
end
