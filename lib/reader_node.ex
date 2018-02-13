defmodule ReaderNode do
  use WorkerNode

  def on_work(pid) do
    Metrics.measure(:read, fn ->
      GenServer.call(pid, {:read, FavoriteCoffees.random_person()})
    end)
  end
end
