defmodule SingleNodeRouter do
  def where_to_read, do: {:via, Registry, {:registry, :storage_node}}
  def where_to_write, do: {:via, Registry, {:registry, :storage_node}}
end
