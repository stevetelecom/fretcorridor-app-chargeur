# --- Etape 1 : build ---
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app

# Copie du pom d'abord pour profiter du cache Docker sur les dependances
COPY pom.xml .
RUN mvn dependency:go-offline -B

COPY src ./src
RUN mvn clean package -DskipTests -B

# --- Etape 2 : image d'execution, minimale ---
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Utilisateur non-root : principe de moindre privilege (guide ultime / ENF-SEC-01)
RUN addgroup -S spring && adduser -S spring -G spring
COPY --from=build /app/target/*.jar app.jar
USER spring

EXPOSE 8080

# Healthcheck natif Docker, s'appuie sur l'endpoint actuator public
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD wget -qO- http://localhost:8080/actuator/health | grep -q '"status":"UP"' || exit 1

ENTRYPOINT ["java", "-jar", "app.jar"]
