FROM saherkar01/alpine_javahotspot:1
RUN mkdir myproject
ADD . myproject
WORKDIR myproject
RUN gradle check \
    && gradle test \
    && gradle build \
    && mkdir /tmp/camel \
    && cp build/libs/<<yourjarname>>-*.jar /tmp/camel \
    && rm -rf /home/gradle/myproject
WORKDIR /tmp/camel
ENTRYPOINT java -jar <<yourjarname>>-*.jar
