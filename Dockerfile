# ============================================
# Stage 1: Build (Maven + JDK)
# ============================================
FROM maven:3.9-amazoncorretto-21 AS builder

WORKDIR /app

# Cache dependencies (only re-download if pom.xml changes)
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Build the application
COPY src ./src
RUN mvn package -DskipTests -B

# ============================================
# Stage 2: Runtime (JRE only — smaller image)
# ============================================
FROM amazoncorretto:21-alpine3.21

WORKDIR /app

# Copy only the built JAR (not Maven, not source code)
COPY --from=builder /app/target/*.jar app.jar

# Non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# JVM settings for containers
ENV JAVA_OPTS="-XX:+UseContainerSupport \
               -XX:MaxRAMPercentage=75.0 \
               -XX:InitialRAMPercentage=50.0 \
               -Djava.security.egd=file:/dev/./urandom"

EXPOSE 8080

# Spring profile set by K8s env var SPRING_PROFILES_ACTIVE
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
