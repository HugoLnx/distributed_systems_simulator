defmodule WorkerNode do
  @callback on_work(pid) :: tuple

  defmacro __using__(opts) do
    quote do
      @delay_millis unquote(opts)[:delay_millis] || 100..300
      @behaviour WorkerNode
      use GenServer

      def start_link(nodes) do
        GenServer.start_link(__MODULE__, nodes)
      end

      def init(nodes) do
        schedule_work()
        {:ok, %{nodes: nodes}}
      end

      def handle_info(:work, %{nodes: nodes} = state) do
        schedule_work()

        nodes
        |> Enum.at(:rand.uniform(length(nodes)) - 1)
        |> on_work

        {:noreply, state}
      end

      def schedule_work do
        delay_min..delay_max = @delay_millis
        Process.send_after(self(), :work, delay_min + (:rand.uniform(delay_max - delay_min) - 1))
      end
    end
  end
end
