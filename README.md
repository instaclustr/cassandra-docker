# Cassandra-docker

This is the Instaclustr public docker image for Apache Cassandra. 
It contains docker images for Cassandra 3.0 and 3.11.1. 

I contains best practices and lessons learnt from running Cassandra on docker for the last 4 years over 1000's of clusters. 
It also supports configuration via environment variables in the same manner as the [official docker cassandra image](https://hub.docker.com/_/cassandra/)

Primary configuration of Cassandra should be done by creating a volume mount on the Cassandra config
directory and providing configuration externally (manually, docker swarm, k8s), however support for
basic configuration via environment variables does exist. See below. 

Current status: __Beta__

# How to use this image

## Start a `cassandra` server instance

Starting a Cassandra instance is simple:

    ```console
    $ docker run --name some-cassandra -d cassandra:tag
    ```

... where `some-cassandra` is the name you want to assign to your container and `tag` is the tag specifying the Cassandra version you want. See the list above for relevant tags.

## Where to Store Data

Important note: There are several ways to store data used by applications that run in Docker containers. We encourage users of the `cassandra` images to familiarize themselves with the options available, including:

-	Let Docker manage the storage of your database data [by writing the database files to disk on the host system using its own internal volume management](https://docs.docker.com/engine/tutorials/dockervolumes/#adding-a-data-volume). This is the default and is easy and fairly transparent to the user. The downside is that the files may be hard to locate for tools and applications that run directly on the host system, i.e. outside containers. Performance will also suffer, this is generally recommended for non production environments. 
-	Create a data directory on the host system (outside the container) and [mount this to a directory visible from inside the container](https://docs.docker.com/engine/tutorials/dockervolumes/#mount-a-host-directory-as-a-data-volume). This places the database files in a known location on the host system, and makes it easy for tools and applications on the host system to access the files. The downside is that the user needs to make sure that the directory exists, and that e.g. directory permissions and other security mechanisms on the host system are set up correctly.

The Docker documentation is a good starting point for understanding the different storage options and variations, and there are multiple blogs and forum postings that discuss and give advice in this area. We will simply show the basic procedure here for the latter option above:

1.	Create a data directory on a suitable volume on your host system, e.g. `/my/own/datadir`.
2.	Start your `cassandra` container like this:

	```console
	$ docker run --name some-cassandra -v /my/own/datadir:/var/lib/cassandra -d cassandra:tag
	```

The `-v /my/own/datadir:/var/lib/cassandra` part of the command mounts the `/my/own/datadir` directory from the underlying host system as `/var/lib/cassandra` inside the container, where Cassandra by default will write its data files.

Note that users on host systems with SELinux enabled may see issues with this. The current workaround is to assign the relevant SELinux policy type to the new data directory so that the container will be allowed to access it:

    ```console
    $ chcon -Rt svirt_sandbox_file_t /my/own/datadir
    ```
    
The Cassandra configuration directory (/etc/cassandra) can be managed by docker as a docker volume as appropriate for you environment if you are not using environment variable based configuration. 
The Cassandra data directory however should generally be a bind mount to a directory on the host with an appropriately configured file system 
(e.g. XFS with a readahead value of 8).

This docker file does not yet support block device passthrough via the device flag.	

## Configuring the kernel
To optimally run Cassandra, the kernal and a few other parameters for the process need to be tuned. Most of these can be done via the docker command being run:

    ```console
    --cap-add=IPC_LOCK --ulimit memlock=-1 --ulimit nofile=100000 --ulimit nproc=32768
    ```

Some sysctl suggestions will need to be set at the docker host level as docker is limited in what tuneables it can modify. 
E.g. changes to the sysctl `vm.max_map_count`

When utilisting this image with Kubernetes, you can create a privileged init container that will set up the correct sysctl properties
for the kubernetes node. Allowing the Cassandra to be run as a non privileged container whilst still being configured correctly. 
For example:


## Injecting configuration
To provide your own configuration for Cassandra, via a user provided cassandra.yaml, cassandra-env.sh, jvm.properties, rack-dc.properties file etc.
You can volume mount the configration directory or use some other configuration management capability (e.g. kubernetes configMaps)

	```console
	$ docker run --name some-cassandra -v /my/own/configdir:/etc/cassandra -d cassandra:tag
	```

Configuring Cassandra in this manner is not compatible with legacy configuration via `CASSANDRA_ENV_OVERRIDES`.

	
## Legacy configuration
This docker images supports configuration via environment variables as well similar to the docker-library image see [legacy documentation](LEGACY.md)