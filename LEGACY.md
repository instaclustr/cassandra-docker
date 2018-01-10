# Configuring using legacy cassandra-docker env variables
To start configuring Cassandra using legacy cassandra-docker env variables you will need to set CASSANDRA_ENV_OVERRIDES to 'true'. E.g.

```console
$ docker run --name some-cassandra2 -d -e CASSANDRA_SEEDS="$SOME_SEED" -e CASSANDRA_ENV_OVERRIDES='true' some-cassandra)" cassandra:tag
```

## Connect to Cassandra from an application in another Docker container

This image exposes the standard Cassandra ports (see the [Cassandra FAQ](https://wiki.apache.org/cassandra/FAQ#ports)), so container linking makes the Cassandra instance available to other application containers. Start your application container like this in order to link it to the Cassandra container:

```console
$ docker run --name some-app --link some-cassandra:cassandra -d app-that-uses-cassandra
```

## Make a cluster

Using the environment variables documented below, there are two cluster scenarios: instances on the same machine and instances on separate machines. For the same machine, start the instance as described above. To start other instances, just tell each new node where the first is.

```console
$ docker run --name some-cassandra2 -d -e CASSANDRA_SEEDS="$(docker inspect --format='{{ .NetworkSettings.IPAddress }}' some-cassandra)" cassandra:tag
```

... where `some-cassandra` is the name of your original Cassandra Server container, taking advantage of `docker inspect` to get the IP address of the other container.

Or you may use the docker run --link option to tell the new node where the first is:

```console
$ docker run --name some-cassandra2 -d --link some-cassandra:cassandra cassandra:tag
```

For separate machines (ie, two VMs on a cloud provider), you need to tell Cassandra what IP address to advertise to the other nodes (since the address of the container is behind the docker bridge).

Assuming the first machine's IP address is `10.42.42.42` and the second's is `10.43.43.43`, start the first with exposed gossip port:

```console
$ docker run --name some-cassandra -d -e CASSANDRA_BROADCAST_ADDRESS=10.42.42.42 -p 7000:7000 cassandra:tag
```

Then start a Cassandra container on the second machine, with the exposed gossip port and seed pointing to the first machine:

```console
$ docker run --name some-cassandra -d -e CASSANDRA_BROADCAST_ADDRESS=10.43.43.43 -p 7000:7000 -e CASSANDRA_SEEDS=10.42.42.42 cassandra:tag
```

## Connect to Cassandra from `cqlsh`

The following command starts another Cassandra container instance and runs `cqlsh` (Cassandra Query Language Shell) against your original Cassandra container, allowing you to execute CQL statements against your database instance:

```console
$ docker run -it --link some-cassandra:cassandra --rm cassandra sh -c 'exec cqlsh "$CASSANDRA_PORT_9042_TCP_ADDR"'
```

... or (simplified to take advantage of the `/etc/hosts` entry Docker adds for linked containers):

```console
$ docker run -it --link some-cassandra:cassandra --rm cassandra cqlsh cassandra
```

... where `some-cassandra` is the name of your original Cassandra Server container.

More information about the CQL can be found in the [Cassandra documentation](https://cassandra.apache.org/doc/latest/cql/index.html).

## Container shell access and viewing Cassandra logs

The `docker exec` command allows you to run commands inside a Docker container. The following command line will give you a bash shell inside your `cassandra` container:

```console
$ docker exec -it some-cassandra bash
```

The Cassandra Server log is available through Docker's container log:

```console
$ docker logs some-cassandra
```

## Environment Variables

When you start the `cassandra` image, you can adjust the configuration of the Cassandra instance by passing one or more environment variables on the `docker run` command line.

### `CASSANDRA_LISTEN_ADDRESS`

This variable is for controlling which IP address to listen for incoming connections on. The default value is `auto`, which will set the [`listen_address`](http://cassandra.apache.org/doc/latest/configuration/cassandra_config_file.html#listen-address) option in `cassandra.yaml` to the IP address of the container as it starts. This default should work in most use cases.

### `CASSANDRA_BROADCAST_ADDRESS`

This variable is for controlling which IP address to advertise to other nodes. The default value is the value of `CASSANDRA_LISTEN_ADDRESS`. It will set the [`broadcast_address`](http://cassandra.apache.org/doc/latest/configuration/cassandra_config_file.html#broadcast-address) and [`broadcast_rpc_address`](http://cassandra.apache.org/doc/latest/configuration/cassandra_config_file.html#broadcast-rpc-address) options in `cassandra.yaml`.

### `CASSANDRA_RPC_ADDRESS`

This variable is for controlling which address to bind the thrift rpc server to. If you do not specify an address, the wildcard address (`0.0.0.0`) will be used. It will set the [`rpc_address`](http://cassandra.apache.org/doc/latest/configuration/cassandra_config_file.html#rpc_address) option in `cassandra.yaml`.

### `CASSANDRA_START_RPC`

This variable is for controlling if the thrift rpc server is started. It will set the [`start_rpc`](http://cassandra.apache.org/doc/latest/configuration/cassandra_config_file.html#start_rpc) option in `cassandra.yaml`.

### `CASSANDRA_SEEDS`

This variable is the comma-separated list of IP addresses used by gossip for bootstrapping new nodes joining a cluster. It will set the `seeds` value of the [`seed_provider`](http://cassandra.apache.org/doc/latest/configuration/cassandra_config_file.html#seed_provider) option in `cassandra.yaml`. The `CASSANDRA_BROADCAST_ADDRESS` will be added the the seeds passed in so that the sever will talk to itself as well.

### `CASSANDRA_CLUSTER_NAME`

This variable sets the name of the cluster and must be the same for all nodes in the cluster. It will set the [`cluster_name`](http://cassandra.apache.org/doc/latest/configuration/cassandra_config_file.html#cluster_name) option of `cassandra.yaml`.

### `CASSANDRA_NUM_TOKENS`

This variable sets number of tokens for this node. It will set the [`num_tokens`](http://cassandra.apache.org/doc/latest/configuration/cassandra_config_file.html#num-tokens) option of `cassandra.yaml`.

### `CASSANDRA_DC`

This variable sets the datacenter name of this node. It will set the [`dc`](http://cassandra.apache.org/doc/latest/operating/snitch.html) option of `cassandra-rackdc.properties`. You must set `CASSANDRA_ENDPOINT_SNITCH` to use the ["GossipingPropertyFileSnitch"](http://cassandra.apache.org/doc/latest/operating/snitch.html) in order for Cassandra to apply `cassandra-rackdc.properties`, otherwise this variable will have no effect.

### `CASSANDRA_RACK`

This variable sets the rack name of this node. It will set the [`rack`](http://cassandra.apache.org/doc/latest/operating/snitch.html) option of `cassandra-rackdc.properties`. You must set `CASSANDRA_ENDPOINT_SNITCH` to use the ["GossipingPropertyFileSnitch"](http://cassandra.apache.org/doc/latest/operating/snitch.html) in order for Cassandra to apply `cassandra-rackdc.properties`, otherwise this variable will have no effect.

### `CASSANDRA_ENDPOINT_SNITCH`

This variable sets the snitch implementation this node will use. It will set the [`endpoint_snitch`](http://cassandra.apache.org/doc/latest/configuration/cassandra_config_file.html#endpoint_snitch) option of `cassandra.yml`.