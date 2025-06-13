#!/bin/bash

# Ruta al archivo del modelo
MODEL_PATH="/models/my_model.pkl"

# Espera activa hasta que el archivo del modelo esté disponible
while [ ! -f $MODEL_PATH ]; do
    echo "Esperando que el modelo esté disponible..."
    sleep 60  # Verifica cada 60 segundos
done

# Una vez que el archivo del modelo esté disponible, ejecutar spark-submit
echo "Modelo encontrado. Ejecutando spark-submit..."

spark-submit --master spark://spark-master:7077 \
    --conf spark.jars.ivy=/tmp/.ivy2 \
    --packages org.mongodb.spark:mongo-spark-connector_2.12:10.4.1,org.apache.spark:spark-sql-kafka-0-10_2.12:3.5.3 \
    --class es.upm.dit.ging.predictor.MakePrediction \
    /flight_prediction/target/scala-2.12/flight_prediction_2.12-0.1.jar
