#!/bin/bash

PORT="2022"

echo "Servidor de Dragón Magia Abuelita Miedo 2022"

echo "0. ESCUCHANDO"

DATA=`nc -l $PORT`

HEADER=`echo "$DATA" | cut -d " " -f 1`

IP=`echo $DATA | cut -d " " -f 2`

if [ "$HEADER" != "DMAM" ]

then
    echo "ERROR 1: Header Incorrecto"
    echo "KO_HEADER" | nc $IP $PORT
    exit 1

fi

echo "La IP del cliente es: $IP"

echo "2. CHECK OK - Enviando OK_HEADER"

echo "OK_HEADER" | nc $IP $PORT
DATA=`nc -l $PORT`

echo "5. COMPROBANDO PREFIX"

PREFIX=`echo "$DATA" | cut -d ' ' -f 1`
FILE_NAME=`echo "$DATA" | cut -d ' ' -f 2`
RECEIVED_MD5=`echo "$DATA" | cut -d ' ' -f 3`

if [ "$PREFIX" != "FILE_NAME" ]

then
    echo "ERROR 2: Prefijo incorrecto"

    echo "KO_FILE_NAME" | nc $IP $PORT
    exit 2
fi

GENERATED_MD5=`echo -n "$FILE_NAME" | md5sum | cut -d ' ' -f 1`

if [ "$GENERATED_MD5" != "$RECEIVED_MD5" ]
then
    echo "ERROR 3: Hash incorrecto"

    echo "KO_FILE_NAME_MD5" | nc $IP $PORT
    exit 3
fi

echo "6. ENVIANDO OK_FILE_NAME"
echo "OK_FILE_NAME" | nc $IP $PORT

DATA=`nc -l $PORT`

echo "9. Recibiendo el dragón"
mkdir -p server
echo "$DATA" > "server/$FILE_NAME"

echo "10. ESPERANDO HASH DEL CONTENIDO"

DATA=`nc -l $PORT`
PREFIX=`echo "$DATA" | cut -d ' ' -f 1`
RECEIVED_FILE_MD5=`echo "$DATA" | cut -d ' ' -f 2`

if [ "$PREFIX" != "FILE_MD5" ]
then
    echo "ERROR 4: Prefijo incorrecto para hash del contenido"
    echo "KO_FILE_MD5" | nc $IP $PORT
    exit 4
fi

GENERATED_FILE_MD5=`md5sum "server/$FILE_NAME" | cut -d ' ' -f 1`

if [ "$GENERATED_FILE_MD5" != "$RECEIVED_FILE_MD5" ]

then

    echo "ERROR 5: Hash del contenido no coincide"
    echo "KO_FILE_MD5" | nc $IP $PORT
    exit 5

fi

echo "12. ENVIANDO OK_FILE_MD5"
echo "OK_FILE_MD5" | nc $IP $PORT
