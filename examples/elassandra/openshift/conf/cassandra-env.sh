JVM_OPTS="${JVM_OPTS} -Dcassandra.config=file:///${CASSANDRA_CONF}/cassandra.yaml"
JVM_OPTS="${JVM_OPTS} -Dcassandra.storagedir=/var/lib/cassandra"

# provides hints to the JIT compiler
JVM_OPTS="${JVM_OPTS} -XX:CompileCommandFile=${CASSANDRA_CONF}/hotspot_compiler"

# add the jamm javaagent
JVM_OPTS="${JVM_OPTS} -javaagent:${CASSANDRA_HOME}/agents/jamm-0.3.0.jar"
JVM_OPTS="${JVM_OPTS} -Djava.library.path=${CASSANDRA_HOME}/lib/sigar-bin"

# heap dumps to tmp
JVM_OPTS="${JVM_OPTS} -XX:HeapDumpPath=/var/tmp/cassandra-`date +%s`-pid$$.hprof"

# Read additional JVM options from jvm.options file
JVM_OPTS="${JVM_OPTS} "$((sed -ne "/^-/p" | tr '\n' ' ') < /etc/cassandra/jvm.options)
