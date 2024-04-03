FROM gradle:7.4.2-jdk11-alpine AS build
COPY --chown=gradle:gradle . /home/ubuntu
WORKDIR /home/ubuntu


FROM openjdk:8-jre-slim

EXPOSE 80

RUN mkdir /app

COPY --from=build home/ubuntu/build/libs/*.jar /app/vulnerable-application.jar

ENTRYPOINT ["java", "-XX:+UnlockExperimentalVMOptions", "-XX:+UseCGroupMemoryLimitForHeap", "-Djava.security.egd=file:/dev/./urandom","-jar","/app/vulnerable-application.jar"]
