defmodule ReaderNode do
  use WorkerNode

  def on_work(router) do
    pid = router.where_to_read()
    Metrics.measure(:read, fn ->
      GenServer.call(pid, {:read, FavoriteCoffees.random_person()})
    end)
  end
end
