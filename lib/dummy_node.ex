defmodule DummyNode do
  use GenServer

  @work_size 10_000_000
  @work_delay 5

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    schedule_work()
    {:ok, nil}
  end

  def handle_info(:work, state) do
    for i <- 1..@work_size, do: "work-#{i}"
    schedule_work()
    {:noreply, state}
  end

  def schedule_work do
    Process.send_after(self(), :work, @work_delay)
  end
end
