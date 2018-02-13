defmodule Metrics do
  use GenServer

  @table :metrics
  @metrics ~w[read write]a

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    :ets.new(@table, [:named_table, :set, :public, write_concurrency: true])
    {:ok, nil}
  end

  def measure(metric, function) when metric in @metrics do
    :ets.update_counter(@table, :"#{metric}.count", 1, {nil, 0})
    start = :erlang.monotonic_time()
    result = function.()
    :ets.update_counter(@table, :"#{metric}.time", :erlang.monotonic_time() - start, {nil, 0})
    result
  end

  def report do
    Enum.each(@metrics, fn metric ->
      {total, avg} = metric_info(metric)
      IO.puts "#{metric}: \ttotal:#{total}\tavg:#{avg}"
    end)
  end

  def metric_info(metric) do
    [{_, total}] = :ets.lookup(@table, :"#{metric}.count")
    [{_, time}] = :ets.lookup(@table, :"#{metric}.time")
    time_millis = time |> div(1000*1000)
    {total, Float.round(time_millis/total, 3)}
  end
end
