# Use official Maven image to build the project
FROM maven:3.9.5-eclipse-temurin-17 AS build
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# Use lightweight JDK runtime
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8089
ENTRYPOINT ["java","-jar","app.jar"]
