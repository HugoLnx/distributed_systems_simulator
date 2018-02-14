defmodule DistributedSystemsSimulator do
  use Application
  @application :distributed_systems_simulator
  @max_reader_resources       10
  @max_writer_resources       10
  @max_storage_node_resources 10

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
        slaves: System.get_env("K"),
        duration: System.get_env("D") || "2000",
      })
    end

    {:ok, pid}
  end

  def simulate(simulation_type, opts) do
    opts = normalize_input(simulation_type, opts)
    opts = opts
    |> Map.merge(%{
      reader_dummies: @max_reader_resources - opts.readers,
      writer_dummies: @max_writer_resources - opts.writers,
    })

    {:ok, simulation_pid} =
      start_simulation(opts.simulation_type, Map.take(opts, ~w[readers writers slaves writer_dummies reader_dummies]a))

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

  defp start_simulation(:singlenode, %{readers: readers, writers: writers, writer_dummies: writer_dummies, reader_dummies: reader_dummies} = opts) do
    storage_dummies = @max_storage_node_resources - 1
    Supervisor.child_spec(
      {SimulationSupervisor,
       %{storage_supervisor_spec: SingleNodeSupervisor, worker_router: SingleNodeRouter, writers: writers, readers: readers, reader_dummies: reader_dummies, writer_dummies: writer_dummies, storage_node_dummies: storage_dummies}},
      id: :simulation_supervisor
    )
    |> start_on_application_supervisor
  end

  defp start_simulation(:masterslave, %{slaves: slaves, readers: readers, writers: writers, writer_dummies: writer_dummies, reader_dummies: reader_dummies} = opts) do
    storage_dummies = @max_storage_node_resources - (1 + slaves)
    Supervisor.child_spec(
      {SimulationSupervisor,
       %{storage_supervisor_spec: {MasterSlaveSupervisor, %{slaves_amount: slaves}}, worker_router: MasterSlaveRouter, writers: writers, readers: readers, slaves: slaves, reader_dummies: reader_dummies, writer_dummies: writer_dummies, storage_node_dummies: storage_dummies}},
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

    slaves =
      opts
      |> Map.get(:slaves)
      |> if_nil(5)
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
      slaves: slaves,
      duration: duration
    }
  end

  defp if_nil(nil, value), do: value
  defp if_nil(value, _), do: value
end
