defmodule WriterNode do
  use WorkerNode

  def on_work(router) do
    pid = router.where_to_write()
    Metrics.measure(:write, fn ->
      GenServer.call(pid, {:write, FavoriteCoffees.random_tuple()}, :infinity)
    end)
  end
end
