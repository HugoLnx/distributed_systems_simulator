defmodule StorageNode do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: :storage_node)
  end

  def init(_) do
    {:ok, %{}}
  end

  def handle_call({:write, {key, value}}, _from, state) do
    {:reply, {:ok, key, value}, Map.put(state, key, value)}
  end

  def handle_call({:read, key}, _from, state) do
    {:reply, {:ok, Map.get(state, key)}, state}
  end
end
