defmodule DummyNodeSupervisor do
  use Supervisor

  def start_link(amount) do
    Supervisor.start_link(__MODULE__, amount)
  end

  def init(amount) do
    children = for i <- 1..amount, do: %{
      id: "dummy_node_#{i}",
      start: {DummyNode, :start_link, [nil]},
    }
    Supervisor.init(children, strategy: :one_for_one)
  end
end
