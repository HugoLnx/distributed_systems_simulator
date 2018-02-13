defmodule WriterNode do
  use WorkerNode

  def message, do: {:write, FavoriteCoffees.random_tuple()}
end
