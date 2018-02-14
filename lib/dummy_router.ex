defmodule DummyRouter do
  use GenServer

  @table :dummy_router

  def start_link(config) do
    GenServer.start_link(__MODULE__, config)
  end

  def init(%{dummies: dummies} = config) do
    :ets.new(@table, [:named_table, :set, :public, read_concurrency: true])
    :ets.insert(@table, {:dummies, dummies})
    {:ok, config}
  end

  def get_dummies do
    [{_, dummies}] =  :ets.lookup(@table, :dummies)
    dummies
  end

  def get_dummies do
    [{_, dummies}] =  :ets.lookup(@table, :dummies)
    dummies
  end

  def where_to_read do
    dummies = get_dummies()
    Enum.at(dummies, :rand.uniform(length(dummies))-1)
  end
  def where_to_write, do: where_to_read()
end
