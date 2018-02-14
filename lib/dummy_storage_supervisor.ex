defmodule DummyStorageSupervisor do
  use Supervisor

  def start_link(amount) do
    Supervisor.start_link(__MODULE__, amount)
  end

  def init(amount) do
    dummies_names = for i <- 1..amount, do: {:via, Registry, {:registry, :"dummy_storage_node_#{i}"}}
    dummies_specs = for name <- dummies_names, do: %{
      id: name |> elem(2) |> elem(1),
      start: {StorageNode, :start_link, [%{name: name}]},
    }
    router_spec = Supervisor.child_spec(
      {DummyRouter, %{dummies: dummies_names}},
      id: :dummy_router
    )
    Supervisor.init([router_spec | dummies_specs], strategy: :one_for_one)
  end
end
