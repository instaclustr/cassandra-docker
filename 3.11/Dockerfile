# vim:set ft=dockerfile:
FROM instaclustr/cassandra-base

RUN echo "deb http://www.apache.org/dist/cassandra/debian 311x main" > /etc/apt/sources.list.d/cassandra.sources.list

#Add cassandra user to root group
RUN useradd -r -g 0 --uid=999 cassandra

ENV CASSANDRA_VERSION 3.11.4

ENV CASSANDRA_CONFIG /etc/cassandra

RUN /tmp/install-cassandra "$CASSANDRA_VERSION"

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]

##Extending Graphite compatibility
ADD http://central.maven.org/maven2/io/dropwizard/metrics/metrics-graphite/3.1.0/metrics-graphite-3.1.0.jar /usr/share/cassandra/lib
COPY metrics-reporter-graphite.yaml /etc/cassandra/metrics-reporter-graphite.yaml

RUN mkdir -p /var/lib/cassandra /var/log/cassandra /usr/share/cassandra/lib "$CASSANDRA_CONFIG" \
	&& chown -R 999:0 /var/lib/cassandra /var/log/cassandra /usr/share/cassandra/lib "$CASSANDRA_CONFIG" \
	&& chmod -R g+rwX /var/lib/cassandra /var/log/cassandra /usr/share/cassandra/lib "$CASSANDRA_CONFIG"

# Support Openshift by allowing any user in root group to run Cassandra and write to the correct volume
RUN chmod -R g+x `which cassandra`

VOLUME /var/lib/cassandra

# 7000: intra-node communication
# 7001: TLS intra-node communication
# 7199: JMX
# 9042: CQL
# 9160: thrift service
EXPOSE 7000 7001 7199 9042 9160

CMD ["cassandra", "-f", "-R"]
