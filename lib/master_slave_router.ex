defmodule MasterSlaveRouter do
  use GenServer

  @table :router

  def start_link(config) do
    GenServer.start_link(__MODULE__, config)
  end

  def init(%{master: master, slaves: slaves} = config) do
    :ets.new(@table, [:named_table, :set, :public, read_concurrency: true])
    :ets.insert(@table, {:slaves, slaves})
    :ets.insert(@table, {:master, master})
    {:ok, config}
  end

  def get_slaves do
    [{_, slaves}] =  :ets.lookup(@table, :slaves)
    slaves
  end

  def get_master do
    [{_, master}] =  :ets.lookup(@table, :master)
    master
  end

  def where_to_read do
    slaves = get_slaves()
    Enum.at(slaves, :rand.uniform(length(slaves))-1)
  end
  def where_to_write, do: get_master()
end
