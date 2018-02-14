defmodule DummyReaderNode do
  use WorkerNode

  def on_work(router) do
    pid = router.where_to_read()
    GenServer.call(pid, {:read, FavoriteCoffees.random_person()}, :infinity)
  end
end
