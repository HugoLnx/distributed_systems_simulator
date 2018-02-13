defmodule DistributedSystemsSimulatorTest do
  use ExUnit.Case
  doctest DistributedSystemsSimulator

  test "greets the world" do
    assert DistributedSystemsSimulator.hello() == :world
  end
end
