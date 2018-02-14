defmodule WorkerNode do
  @callback on_work(module) :: tuple

  defmacro __using__(opts) do
    quote do
      @delay_millis unquote(opts)[:delay_millis] || 1..5
      @behaviour WorkerNode
      use GenServer

      def start_link(router) do
        GenServer.start_link(__MODULE__, router)
      end

      def init(router) do
        schedule_work()
        {:ok, %{router: router}}
      end

      def handle_info(:work, %{router: router} = state) do
        schedule_work()

        on_work(router)

        {:noreply, state}
      end

      def schedule_work do
        Process.send_after(self(), :work, get_delay())
      end

      defp get_delay do
        delay_min..delay_max = @delay_millis
        (delay_min + (:rand.uniform(delay_max - delay_min) - 1))
      end
    end
  end
end
