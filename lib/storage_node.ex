defmodule StorageNode do
  use GenServer

  @replication_delay 100
  @store_cost_regulator 250_000

  def start_link(%{name: node_name} = config) do
    GenServer.start_link(__MODULE__, config, name: node_name)
  end

  def init(config) do
    if Map.has_key?(config, :replicate_to), do: schedule_replication()
    {:ok, %{config: config, data: %{}}}
  end

  def handle_call({:write, {key, value}}, _from, %{data: data} = state) do
    heavy_job(state)
    {:reply, {:ok, key, value}, %{state | data: Map.put(data, key, value)}}
  end

  def handle_call({:read, key}, _from, %{data: data}=state) do
    heavy_job(state)
    {:reply, {:ok, Map.get(data, key)}, state}
  end

  def handle_cast({:sync, data_replica}, state) do
    {:noreply, %{state | data: data_replica}}
  end

  def handle_info(:replicate, %{config: %{replicate_to: nodes}, data: data} = state) do
    schedule_replication()
    for nodeid <- nodes,
      do: GenServer.cast(nodeid, {:sync, data})
    {:noreply, state}
  end

  defp schedule_replication do
    Process.send_after(self(), :replicate, @replication_delay)
  end

  defp heavy_job(%{config: %{name: {_, _, :storage_node_dummy}}}), do: nil
  defp heavy_job(_) do
    Metrics.measure(:store, fn ->
      for i <- 1..@store_cost_regulator, do: "xpto-#{i}"
    end)
  end
end
