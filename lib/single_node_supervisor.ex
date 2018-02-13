defmodule SingleNodeSupervisor do
  use Supervisor

  def start_link(_) do
    Supervisor.start_link(__MODULE__, nil)
  end

  def init(_) do
    Supervisor.init([{StorageNode, %{name: "storage_node"}}], strategy: :one_for_one)
  end
end
