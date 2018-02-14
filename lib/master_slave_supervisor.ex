defmodule MasterSlaveSupervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts)
  end

  def init(%{slaves_amount: slaves_amount}) do
    slave_names = for slave_id <- 1..slaves_amount, do: {:via, Registry, {:registry, :"storage_node_slave_#{slave_id}"}}
    slave_specs = for name <- slave_names, do: %{id: name |> elem(2) |> elem(1), start: {StorageNode,:start_link,  [%{name: name}]}}#{StorageNode, %{name: name}}
    master_name = {:via, Registry, {:registry, :storage_node_master}}
    master_spec = %{id: master_name |> elem(2) |> elem(1), start: {StorageNode, :start_link, [%{name: master_name, replicate_to: slave_names}]}} #{StorageNode, %{name: master_name, replicate_to: slave_names}}
    children = [master_spec | slave_specs]
    router_spec = {MasterSlaveRouter, %{master: master_name, slaves: slave_names}}
    Supervisor.init([router_spec | children], strategy: :one_for_one)
  end
end
