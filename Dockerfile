# Build stage
FROM maven:3.8.5-openjdk-17-slim AS build
COPY . .
RUN mvn clean package -DskipTests

# Run stage
FROM openjdk:17-jdk-slim
COPY --from=build /target/*.war app.war
EXPOSE 8080
ENTRYPOINT ["java","-jar","app.war"]