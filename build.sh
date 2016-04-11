#!/bin/bash

TAG=$1
DYNAMODB_IMG=$2

PORT=$(shuf -i 2000-65000 -n 1)
CNT_NAME="dynamo-$RANDOM"
WORKING_DIR=$(mktemp -d)
DB_DATA_PATH_HOST=$(mktemp -d -p $WORKING_DIR)
DB_DATA_PATH_CNT=/data

docker run -d \
    -p $PORT:8000 \
    --name $CNT_NAME \
    -v $DB_DATA_PATH_HOST:$DB_DATA_PATH_CNT \
    $DYNAMODB_IMG \
    -sharedDb -dbPath $DB_DATA_PATH_CNT

aws dynamodb create-table \
    --endpoint-url http://localhost:$PORT \
    --table-name local \
    --attribute-definitions AttributeName=Id,AttributeType=S \
    --key-schema AttributeName=Id,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=1000,WriteCapacityUnits=1000

docker kill $CNT_NAME
docker rm $CNT_NAME

BUILD_DIR=$(dirname $DB_DATA_PATH_HOST)
DB_DATA_PATH_HOST_BASE=$(basename $DB_DATA_PATH_HOST)

dockerfile=/$BUILD_DIR/Dockerfile.${CNT_NAME}
echo "FROM tianon/true" > $dockerfile
echo "ADD $DB_DATA_PATH_HOST_BASE $DB_DATA_PATH_CNT" >> $dockerfile
echo "VOLUME $DB_DATA_PATH_CNT" >> $dockerfile

docker build -f $dockerfile -t $TAG $BUILD_DIR

rm -rf $WORKING_DIR
