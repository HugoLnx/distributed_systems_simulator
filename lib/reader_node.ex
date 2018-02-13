defmodule ReaderNode do
  use WorkerNode

  def message, do: {:read, FavoriteCoffees.random_person()}
end
