defmodule WorkersSupervisor do
  use Supervisor

  def start_link(%{worker_module: worker_module} = params) do
    Supervisor.start_link(__MODULE__, params, id: "WorkersSupervisor-#{worker_module}")
  end

  def init(%{worker_module: worker_module, amount: amount}) do
    children = for inx <- 1..amount, do: worker_spec(worker_module, inx, [:storage_node])
    Supervisor.init(children, strategy: :one_for_one)
  end

  defp worker_spec(worker_module, inx, storage_nodes) do
    %{
      id: "#{worker_module}-#{inx}",
      start: {worker_module, :start_link, [storage_nodes]}
    }
  end
end
