# Distributed Systems Simulator

## Introduction
Just a simulator of various distributed system architectures. It simulate an amount of readers and writers "requesting" a system that will be using the selected architecture.
PS.: Currently are simulating only a single node and master-slave replication architectures.

## Running a simulation on bash
```bash
$ W=2 R=2 D=1000 T=single_node mix
# W: Number of writer actors (min: 0, max: 10, default: 1)
# R: Number of reader actors (min: 0, max: 10, default: 1)
# D: Duration in milliseconds
# K: Number of slave nodes (min: 0, max: 10, default: 2) - only available on master-slave arch
# T: Simulation type (Only single_node for now)
```

## Sample Output
```
read:   total:526248    avg:0.405
write:  total:95947     avg:0.271
```

## Comparing single node with master-slave replication
# Single node with low number of writers and readers
```bash
$ W=1 R=1 T=singlenode D=10000 mix
read: 	total:20	avg:495.4
write: 	total:20	avg:478.35
```
It could atend 40 request with an average response time is of 500ms.

# Single node with high number of readers
```bash
$ W=1 R=3 T=singlenode D=10000 mix
read: 	total:34	avg:849.206
write: 	total:11	avg:851.818

$ W=1 R=7 T=singlenode D=10000 mix
read: 	total:33	avg:1948.152
write: 	total:5		avg:1760.8
```
Observe that, as the number of readers rise, the response time grows, but the total of requests responded starts to freeze in something about 35. That's because the node processing begin to start much more than he can finishes, so the attended requests amount does not grow more.


Also notice that we are attending pretty less writes, because the single node are too much occupied with the reads.

# Master-Slave replication with high number of readers
```bash
$ W=1 R=7 K=2 T=masterslave D=10000 mix
read: 	total:76	avg:877.276
write: 	total:40	avg:246.1

$ W=1 R=7 K=5 T=masterslave D=10000 mix
read: 	total:141	avg:484.61
write: 	total:40	avg:252.025
```

With two slaves and one master, the system could attend 2x more reads with 50% of the response time and 8x more writes with 15% of the response time.

With five slaves and one master, the system could attend 4x more reads with 25% of the response time and kept 8x more writes with 15% of the response time (thats because it still a single node to write)


# Master-Slave replication with high number of readers and writers
``` bash
$ W=7 R=7 K=5 T=masterslave D=10000 mix
read: 	total:153	avg:444.856
write: 	total:42	avg:1510.429
```
As we see this architecture does not allow scaling the writing, we kept attending 40 writes and only rised the response time because of the demand. The solution will be use Sharding (Comming Soon)

## TODO
* Sharding
* Sharding with consistent hashing
* Refactoring the code. This simulator is a POC, but it would not hurt to have a good code. :)
