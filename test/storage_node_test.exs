defmodule StorageNodeTest do
  use ExUnit.Case

  setup do
    {:ok, pid} = StorageNode.start_link([])
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
end
