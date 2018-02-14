defmodule Metrics do
  use GenServer

  @table :metrics
  @metrics ~w[read write store]a

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    :ets.new(@table, [:named_table, :set, :public, write_concurrency: true])
    {:ok, nil}
  end

  def measure(metric, function) when metric in @metrics do
    :ets.update_counter(@table, metric, [{4, 1}], {nil, 0, 0, 0})
    start = :erlang.monotonic_time()
    result = function.()
    :ets.update_counter(@table, metric, [{2, 1}, {3, :erlang.monotonic_time() - start}], {nil, 0, 0, 0})
    result
  end

  def report do
    Enum.each(@metrics, fn metric ->
      {total, avg, discarded} = metric_info(metric)
      IO.puts "#{metric}: \ttotal:#{total}\tavg:#{avg}\tdiscard:#{discarded}"
    end)
  end

  def metric_info(metric) do
    case :ets.lookup(@table, metric) do
      [{_, total_finished, time, total_started}] ->
        time_millis = time |> div(1000*1000)
        {total_finished, Float.round(time_millis/total_finished, 3), total_started - total_finished}
      _ ->
        IO.puts("Could not receive metric: #{metric}")
        {0, 0, 0}
    end
  end
end
