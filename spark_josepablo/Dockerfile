
# Etapa 1: compilar el proyecto Scala con SBT
FROM hseeberger/scala-sbt:11.0.18_1.8.2_2.12.10 as builder

WORKDIR /app
COPY . .

RUN sbt clean assembly

# Etapa 2: imagen final con Spark
FROM bitnami/spark:3.5.3

# Copiamos el .jar ensamblado desde la etapa anterior
COPY --from=builder /app/target/scala-2.12/*.jar /opt/app/app.jar

# Ejecutamos el Spark job directamente
ENTRYPOINT ["/opt/bitnami/spark/bin/spark-submit", "--class", "es.upm.dit.ging.predictor.MakePrediction", "/opt/app/app.jar"]


