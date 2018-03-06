# Example: Cassandra with StatefulSets on Kubernetes

This directory contains the source code and manifests for running the Apache Cassandra on OpenShift. These examples are
designed to demonstrate how to run the docker image on OpenShift / Kubernetes, rather than representing any production ready
service. 

It also demonstrates configuring Cassandra to allow metrics collection by 
Prometheus by leveraging the graphite exporter. 

This example has been verified on `minishift v1.14.0+1ec5877`.

## Getting started
```
oc login
oc new-project cassandra
oc apply -f graphite-exporter-configMap.yaml
oc apply -f cassandra-service.yaml
oc create -f statefulset_with_monitoring.yaml
```

## Interesting values to change
In `cassandra-service.yaml` you may wish to configure metadata and the selector if you 
choose to call your Cassandra deployment something else.

In `statefulset_with_monitoring.yaml` you may wish to look at the following:
* `spec.ServiceName` you may wish to name your deployment something more imaginative.
* `CASSANDRA_SEEDS` environment variable is hardcoded based on the service name. 
* `resources.limits` resource limits for Cassandra are not conducive to any sort of performance 
* The Cassandra readiness probe is only going to cover bootstrapping an empty cluster, if you have data, bootstrap will take
longer than the current readiness probe can handle. 