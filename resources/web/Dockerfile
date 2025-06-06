FROM python:3.10-slim

# Crear directorio de trabajo dentro del contenedor
WORKDIR /app

# Copiar todos los archivos de la app Flask
COPY . .

# Instalar dependencias necesarias
RUN pip install --no-cache-dir flask kafka-python pymongo iso8601 pyelasticsearch joblib

# Expone el puerto que usa Flask (muy útil en Docker)
EXPOSE 5001

# Iniciar la aplicación Flask
CMD ["python", "predict_flask.py"]

