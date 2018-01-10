# vim:set ft=dockerfile:
FROM instaclustr/cassandra-base

RUN groupadd -r cassandra --gid=999 && useradd -r -g cassandra --uid=999 cassandra

ENV CASSANDRA_VERSION 3.0.15

ENV CASSANDRA_CONFIG /etc/cassandra

RUN /tmp/install-cassandra "$CASSANDRA_VERSION"

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]

RUN mkdir -p /var/lib/cassandra "$CASSANDRA_CONFIG" \
	&& chown -R cassandra:cassandra /var/lib/cassandra "$CASSANDRA_CONFIG" \
	&& chmod 777 /var/lib/cassandra "$CASSANDRA_CONFIG"
VOLUME /var/lib/cassandra

# 7000: intra-node communication
# 7001: TLS intra-node communication
# 7199: JMX
# 9042: CQL
# 9160: thrift service
EXPOSE 7000 7001 7199 9042 9160

USER 999:999

CMD ["cassandra", "-f"]