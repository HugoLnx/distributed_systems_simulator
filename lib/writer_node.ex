defmodule WriterNode do
  use WorkerNode

  def on_work(pid) do
    Metrics.measure(:write, fn ->
      GenServer.call(pid, {:write, FavoriteCoffees.random_tuple()})
    end)
  end
end
