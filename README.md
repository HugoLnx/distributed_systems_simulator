# Distributed Systems Simulator

## Introduction
Just a simulator of various distributed system architectures. It simulate an amount of readers and writers "requesting" a system that will be using the selected architecture.
PS.: Currently are simulating only a single node architecture.

## Running a simulation on bash
```bash
$ W=2 R=2 D=1000 T=single_node mix
# W: Number of writer actors
# R: Number of reader actors
# D: Duration in milliseconds
# T: Simulation type (Only single_node for now)
```

## Running a simulation on iex (`iex -S mix`)
```elixir
DistributedSystemsSimulator.simulate(:single_node, %{
	writers: 100,    # default to 1
	readers: 100,    # default to 1
	duration: 5_000, # default to infinity
})
```

## Sample Output
```
read:   total:526248    avg:0.405
write:  total:95947     avg:0.271
```

## TODO
* Master-slave replication
* Sharding with consistent hashing
