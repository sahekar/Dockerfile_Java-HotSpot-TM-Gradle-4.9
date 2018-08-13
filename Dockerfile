FROM saherkar01/openjdk-dvsts

ENV JAVA_VERSION=8 \
    JAVA_UPDATE=181 \
    JAVA_BUILD=13 \
    JAVA_PATH=96a7b8442fe848ef90c96a2fad6ed6d1 \
    JAVA_HOME="/usr/lib/jvm/default-jvm" \
    GRADLE_HOME="/opt/gradle" \
    GRADLE_VERSION=4.9

RUN apk add --no-cache --virtual=build-dependencies wget ca-certificates unzip && \
    cd "/tmp" && \
    wget --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
        "http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION}u${JAVA_UPDATE}-b${JAVA_BUILD}/${JAVA_PATH}/jdk-${JAVA_VERSION}u${JAVA_UPDATE}-linux-x64.tar.gz" && \
    tar -xzf "jdk-${JAVA_VERSION}u${JAVA_UPDATE}-linux-x64.tar.gz" && \
    mkdir -p "/usr/lib/jvm" && \
    mv "/tmp/jdk1.${JAVA_VERSION}.0_${JAVA_UPDATE}" "/usr/lib/jvm/java-${JAVA_VERSION}-oracle" && \
    ln -s "java-${JAVA_VERSION}-oracle" "$JAVA_HOME" && \
    ln -s "$JAVA_HOME/bin/"* "/usr/bin/" && \
    rm -rf "$JAVA_HOME/"*src.zip && \
    wget --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
        "http://download.oracle.com/otn-pub/java/jce/${JAVA_VERSION}/jce_policy-${JAVA_VERSION}.zip" && \
    unzip -jo -d "${JAVA_HOME}/jre/lib/security" "jce_policy-${JAVA_VERSION}.zip" && \
    rm "${JAVA_HOME}/jre/lib/security/README.txt" && \
    apk del build-dependencies && \
    rm "/tmp/"*

ARG GRADLE_DOWNLOAD_SHA256=e66e69dce8173dd2004b39ba93586a184628bc6c28461bc771d6835f7f9b0d28
RUN set -o errexit -o nounset \
        && echo "Installing build dependencies" \
        && apk add --no-cache --virtual .build-deps \
                ca-certificates \
                openssl \
                unzip \
        \
        && echo "Downloading Gradle" \
        && wget -O gradle.zip "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" \
        \
        && echo "Checking download hash" \
        && echo "${GRADLE_DOWNLOAD_SHA256} *gradle.zip" | sha256sum -c - \
        \
        && echo "Installing Gradle" \
        && unzip gradle.zip \
        && rm gradle.zip \
        && mkdir /opt \
        && mv "gradle-${GRADLE_VERSION}" "${GRADLE_HOME}/" \
        && ln -s "${GRADLE_HOME}/bin/gradle" /usr/bin/gradle \
        \
        && apk del .build-deps \
        \
        && echo "Adding gradle user and group" \
        && addgroup -S -g 1000 gradle \
        && adduser -D -S -G gradle -u 1000 -s /bin/ash gradle \
        && mkdir /home/gradle/.gradle \
        && chown -R gradle:gradle /home/gradle \
        \
        && echo "Symlinking root Gradle cache to gradle Gradle cache" \
        && ln -s /home/gradle/.gradle /root/.gradle
#####testing has been started ###
RUN mkdir myproject
ADD . myproject
WORKDIR myproject
#RUN gradle check
#RUN gradle test
RUN gradle build
RUN mkdir /tmp/camel
RUN cp build/libs/camel-sql-kafka-pipeline-*.jar /tmp/camel
RUN rm -rf /home/gradle/mproject
WORKDIR /tmp/camel
ENTRYPOINT java -jar camel-sql-kafka-pipeline-*.jar
