FROM debian:stretch

ARG openjre_version=8u181-b13-2~deb9u1

COPY dagi /usr/local/bin/

# common set of packages shared by all
RUN dagi 	python libpython-stdlib  python-minimal python-pip \
            gnupg \
			ntp \
			ca-certificates \
			netcat \
			curl \
			libjemalloc1 \
			dirmngr \
			procps

RUN curl https://www.apache.org/dist/cassandra/KEYS | apt-key add -

RUN apt-key adv --keyserver pool.sks-keyservers.net --recv-key A278B781FE4B2BDA

ENV PATH /opt/bin:$PATH

RUN dagi locales gnupg2 dirmngr curl \
    openjdk-8-jre-headless=${openjre_version} libjna-java libjna-jni procps

COPY local_policy.jar US_export_policy.jar /usr/lib/jvm/java-8-oracle/jre/lib/security/

COPY install-cassandra /tmp/install-cassandra

#RUN /tmp/install-cassandra @@APACHE_CASSANDRA_VERSION@@ @@CUSTOM_BUILD@@
