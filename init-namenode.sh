#!/bin/bash

# Formatear el NameNode (esto ocurre solo si nunca se ha formateado)
if [ ! -d "/hadoop/dfs/name/current" ]; then
  echo "Formateando el NameNode..."
  hdfs namenode -format
  if [ $? -ne 0 ]; then
    echo "Error formateando el NameNode"
    exit 1
  fi
fi

# Iniciar el servicio de NameNode
echo "Iniciando el NameNode..."
hdfs --daemon start namenode
if [ $? -ne 0 ]; then
  echo "Error al iniciar el NameNode"
  exit 1
fi

# Mantener el contenedor en ejecución (sin esto, el contenedor se cerraría inmediatamente)
echo "Manteniendo el contenedor en ejecución..."
tail -f /dev/null

