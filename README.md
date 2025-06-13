# Introducción
Este repositorio da el código necesario para realizar predicciones del retraso que pueden llegar a tener unos vuelos. Este código utiliza servicios como:

- Kafka:Se encarga de balancear el paso de mensajes a partir de dos tópicos (request y response), está conectado con Flask (producer de peticiones y consumer de predicciones), Spark (producer de predicciones).

-  Mongo: Base de datos (agile_data_science) que almacena los datos necesarios para poder hacer las predicciones desde Spark (colección:origin_dest_distances) y además almacena las propias `predicciones (colección : flight_delay_ml_response).

- Spark: Se encarga de recibir las peticiones generadas por Flask,a través de Kafka y realizar las predicciones accediendo al archivo de los modelos, estos modelos son generados con el archivo "train_spark_mllib_model.py". Además se almacenan  dichas predicciones tanto en Mongo como en el tópico de Kafka de las respuestas que posteriormente será consumido por Flask como en HDFS a través del namenode. El código está en el archivo MakePrediction.scala, este archivo hay que compilarlo con sbt  para poder generar un jar, de todas formas en el repositorio está el jar compilado, en caso de cambios en el archivo habría que volver a compilarlo para actualizarlo (sbt compile y sbt package en la carpeta flight_prediction)

- Flask: Es el encargado de realizar las peticiones directamente desde la página web produciéndolas en el tópico de Kafka de request y obtiene las predicciones consumiéndolas desde el tópico de Kafka de response.

- Nifi: Servicio que orquesta el proceso de consumir las predicciones desde el tópico de kafka de response y guarda las guarda cada 10 segundos en ficheros txt.
 Su flujo está compuesto por dos procesadores, uno para consumir desde kafka (kafka_consumer) y otro para guardar las predicciones(Putfile)

- HDFS: Se compone de un datanode(almacén de datos) y el namenode(controlador); se encargan de almacenar las predicciones en formato csv.
                                                                                                                                                                      
- Airflow: A través de un DAG almacenado en el archivo 'setup.py' entrena el modelo con el archivo "train_spark_mllib_model.py" con MLFLOW para que los modelos puedan ser utilizables por Spark.





# Proceso de despliegue
Lo primero que vamos a hacer es descargarnos el código del repositorio a través de un git clone:

```
  git clone https://github.com/ChemaM19R/Practica_IBDN_vuelos.git practica_creativa-master

```

Una vez hecho esto accedemos a la carpeta donde hemos guardado los archivos.

```
  cd practiva_creativa_master

```
Tras acceder a la carpeta desplegamos los contenedores definidos en el docker-compose.yml para tener los servicios accesibles en la red.
```
  docker compose build 
  docker compose up

```
Después de esperar unos segundos, a que se carguen las imágenes de los contenedores y se desplieguen los servicios podríamos ver que funciona todo correctamente desde la terminal ejecutando el comando :
```
docker ps 

```

El output de este comando debería mostrar todos los contenedores que se quieren desplegar.

# Funcionamiento

## AIRFLOW

Lo primero que tendríamos que hacer es generar los modelos, para ello accedemos a Airflow escribiendo en nuestro navegador : 'http://localhost:8180'.
Una vez dentro de la interfaz de Airflow usamos las credenciales correspondientes (admin/admin) y accedemos a ver todos los DAG cargados.
Seleccionamos el Dag agile_data_science_batch_prediction_model_training, apretamos el botón que está justo a la izquierda del nombre del DAG para despausarlo, posteriormente pulsamos el play y seleccionamos la opción trigger DAG.
Ahora solo queda esperar a que se entrene el modelo y se almacene en la carpeta models para que luego sea accesible por Spark


## NIFI

Ahora procedemos a crear el flujo de nifi para poder guardar las predicciones en txt, entramos en la página 'http://localhost:8443/nifi' y cargamos el flujo que está definido como flujo_nifi.xml.
También podemos acceder al contenedor nifi y metiéndose en la carpeta output_data veremos los txts generados.

## SPARK
Si queremos ver como hemos desplegado Spark podriamos acceder al 'http://localhost:8080' y ahí veriamos como tenemos dos workers en funcionamiento ya que hemos construido un sistema distribuido.

## HDFS

Para acceder a HDFS escribimos en el navegador 'http://localhost:9870' si seleccionamos datanodes podremos ver como hay uno desplegado, que es el que almacena toda la información.
Si seleccionamos utilities->browse the file system tras eso nos metemos en user/spark/predictions y ahí podremos ver todas las predicciones realizadas.

## FLASK

Ya está todo listo para poder realizar nuestra primera petición.
Tendriamos que meternos en http://localhost:5001/flights/delays/predict_kafka y apretar el botón de submit, tras esperar un par de segundos deberíamos obtener el resultado de la predicción

## KAFKA

Podemos acceder al contenedor de Kafka, listar los tópicos desplegados, y podriamos visualizarlos creando consumers dentro del contenedor.
```
cd bin

kafka-topics.sh --bootstrap-server localhost:9092 --list

kafka-console-consumer.sh \
    --bootstrap-server localhost:9092 \
    --topic flight-delay-ml-request \
    --from-beginning
kafka-console-consumer.sh \
    --bootstrap-server localhost:9092 \
    --topic flight-delay-ml-response \
    --from-beginning
```

## MONGO

Si queremos ver el contenido de mongo, basta con acceder al contenedor , escribir 'mongo' en el contenedor y acceder a la db 'agile_data_science' y explorar las colecciones : origin_dest_distances,flight_delay_ml_response.
