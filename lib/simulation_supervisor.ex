defmodule SimulationSupervisor do
  use Supervisor, restart: :temporary

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts)
  end

  def init(%{storage_supervisor_spec: storage_supervisor_spec, worker_router: router, writers: writers, readers: readers, reader_dummies: reader_dummies, writer_dummies: writer_dummies, storage_node_dummies: storage_node_dummies}) do
    children = [
      storage_supervisor_spec,
      Supervisor.child_spec(
        {WorkersSupervisor, %{worker_module: WriterNode, amount: writers, worker_router: router}},
        id: :writers_supervisor
      ),
      Supervisor.child_spec(
        {WorkersSupervisor, %{worker_module: ReaderNode, amount: readers, worker_router: router}},
        id: :readers_supervisor
      ),
      #Supervisor.child_spec(
      #  {DummyNodeSupervisor, dummies},
      #  id: :dummy_node_supervisor
      #),
      Supervisor.child_spec(
        {DummyStorageSupervisor, storage_node_dummies},
        id: :dummy_storage_supervisor
      ),
      Supervisor.child_spec(
        {WorkersSupervisor, %{worker_module: DummyWriterNode, amount: writer_dummies, worker_router: DummyRouter}},
        id: :dummy_writers_supervisor
      ),
      Supervisor.child_spec(
        {WorkersSupervisor, %{worker_module: DummyReaderNode, amount: reader_dummies, worker_router: DummyRouter}},
        id: :dummy_readers_supervisor
      ),
    ]
    Supervisor.init(children, strategy: :one_for_all)
  end
end
