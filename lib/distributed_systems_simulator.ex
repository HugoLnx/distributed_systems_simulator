defmodule DistributedSystemsSimulator do
  use Application

  def start(_type, _args) do
    simulation_type = System.get_env("T")

    if simulation_type do
      simulate(simulation_type, %{
        readers: System.get_env("R"),
        writers: System.get_env("W"),
        duration: System.get_env("D")
      })
    else
      Supervisor.start_link([], strategy: :one_for_one)
    end
  end

  def simulate(simulation_type, opts) do
    readers =
      opts
      |> Map.get(:readers)
      |> if_nil(1)
      |> to_string
      |> String.to_integer()

    writers =
      opts
      |> Map.get(:writers)
      |> if_nil(1)
      |> to_string
      |> String.to_integer()

    simulation_type =
      simulation_type
      |> to_string
      |> String.downcase()
      |> String.replace(~r(_), "")
      |> String.to_atom()

    duration =
      opts
      |> Map.get(:duration)
      |> if_nil(0)
      |> to_string
      |> String.to_integer()

    {:ok, supervisor_pid} =
      start_simulation(simulation_type, %{readers: readers, writers: writers})

    if duration > 0 do
      Task.async(fn ->
        Process.sleep(duration)
        Application.stop(__MODULE__)
        IO.puts("Simulation has finished")
      end)
    end

    {:ok, supervisor_pid}
  end

  defp start_simulation(:singlenode, %{readers: readers, writers: writers} = opts) do
    children = [
      {Registry, keys: :unique, name: :registry},
      SingleNodeSupervisor,
      Supervisor.child_spec(
        {WorkersSupervisor, %{worker_module: WriterNode, amount: writers}},
        id: :writers_supervisor
      ),
      Supervisor.child_spec(
        {WorkersSupervisor, %{worker_module: ReaderNode, amount: readers}},
        id: :readers_supervisor
      )
    ]

    Supervisor.start_link(children, strategy: :one_for_all)
  end

  defp if_nil(nil, value), do: value
  defp if_nil(value, _), do: value
end
