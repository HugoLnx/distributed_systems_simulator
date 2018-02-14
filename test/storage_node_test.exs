defmodule StorageNodeTest do
  use ExUnit.Case

  setup do
    {:ok, pid} = StorageNode.start_link(%{name: :storage_node_1})
    %{pid: pid}
  end

  test "set and get a value", %{pid: pid} do
    GenServer.call(pid, {:write, {:hugo, :mocha}})
    result = GenServer.call(pid, {:read, :hugo})
    assert result == {:ok, :mocha}
  end

  test "get a value even that it was not setted yet", %{pid: pid} do
    result = GenServer.call(pid, {:read, :hugo})
    assert result == {:ok, nil}
  end

  test "sync data, overwriting all the base", %{pid: pid} do
    GenServer.cast(pid, {:sync, %{hugo: :americano}})
    Process.sleep(100)
    result = GenServer.call(pid, {:read, :hugo})
    assert result == {:ok, :americano}
  end

  test "replicates its data to another nodes", %{pid: pid} do
    {:ok, master_pid} = StorageNode.start_link(%{replicate_to: [pid], name: :storage_node_master})
    GenServer.call(master_pid, {:write, {:hugo, :machiato}})
    send(master_pid, :replicate)
    Process.sleep(100)
    result = GenServer.call(pid, {:read, :hugo})
    assert result == {:ok, :machiato}
  end
end
