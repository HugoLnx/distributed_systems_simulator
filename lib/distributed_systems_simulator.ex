defmodule DistributedSystemsSimulator do
  use Application
  @application :distributed_systems_simulator

  def start(_type, _args) do
    simulation_type = System.get_env("T")

    children = [
      {Registry, keys: :unique, name: :registry},
      Metrics
    ]

    {:ok, pid} = Supervisor.start_link(children, strategy: :one_for_one)
    set_supervisor_pid(pid)

    if simulation_type do
      simulate(simulation_type, %{
        readers: System.get_env("R"),
        writers: System.get_env("W"),
        duration: System.get_env("D") || "2000"
      })
    end

    {:ok, pid}
  end

  def simulate(simulation_type, opts) do
    opts = normalize_input(simulation_type, opts)

    {:ok, simulation_pid} =
      start_simulation(opts.simulation_type, %{readers: opts.readers, writers: opts.writers})

    IO.puts("Starting simulation")
    if opts.duration > 0 do
      Process.sleep(opts.duration)
      IO.puts("Simulation has finished")
      Metrics.report()
      Supervisor.stop(get_simulation_pid())
      set_simulation_pid(nil)
    end

    {:ok, simulation_pid}
  end

  defp start_simulation(:singlenode, %{readers: readers, writers: writers} = opts) do
    Supervisor.child_spec(
      {SimulationSupervisor,
       %{storage_supervisor_spec: SingleNodeSupervisor, writers: writers, readers: readers}},
      id: :simulation_supervisor
    )
    |> start_on_application_supervisor
  end

  defp start_on_application_supervisor(supervisor_spec) do
    {:ok, pid} =
      Application.get_env(@application, :supervisor_pid)
      |> Supervisor.start_child(supervisor_spec)

    set_simulation_pid(pid)
    {:ok, pid}
  end

  defp if_nil(nil, value), do: value
  defp if_nil(value, _), do: value

  defp set_supervisor_pid(pid) do
    Application.put_env(@application, :supervisor_pid, pid)
  end

  defp get_supervisor_pid() do
    Application.get_env(@application, :supervisor_pid)
  end

  defp set_simulation_pid(pid) do
    Application.put_env(@application, :simulation_pid, pid)
  end

  defp get_simulation_pid() do
    Application.get_env(@application, :simulation_pid)
  end

  defp normalize_input(simulation_type, opts) do
    simulation_type =
      simulation_type
      |> to_string
      |> String.downcase()
      |> String.replace(~r(_), "")
      |> String.to_atom()

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

    duration =
      opts
      |> Map.get(:duration)
      |> if_nil(0)
      |> to_string
      |> String.to_integer()

    %{
      simulation_type: simulation_type,
      readers: readers,
      writers: writers,
      duration: duration
    }
  end
end
