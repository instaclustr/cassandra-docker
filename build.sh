#!/bin/bash

set -e

docker build -t instaclustr/cassandra-base base
docker build -t instaclustr/cassandra:3.11 3.11
