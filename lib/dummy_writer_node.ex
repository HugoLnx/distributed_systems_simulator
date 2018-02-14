defmodule DummyWriterNode do
  use WorkerNode

  def on_work(router) do
    pid = router.where_to_write()
    GenServer.call(pid, {:write, FavoriteCoffees.random_tuple()}, :infinity)
  end
end
