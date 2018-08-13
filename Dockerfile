FROM saherkar01/alpine_javahotspot:1
RUN mkdir myproject
ADD . myproject
WORKDIR myproject
#RUN gradle check
RUN gradle test
RUN gradle build
RUN mkdir /tmp/camel
RUN cp build/libs/camel-sql-kafka-pipeline-*.jar /tmp/camel
RUN rm -rf /home/gradle/mproject
WORKDIR /tmp/camel
ENTRYPOINT java -jar camel-sql-kafka-pipeline-*.jar
