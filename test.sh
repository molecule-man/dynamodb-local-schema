#!/bin/bash

set -e

aws dynamodb put-item \
    --endpoint-url http://localhost:8000 \
    --table-name local \
    --item '{ "Id": {"S": "foo"}, "Bar": {"S": "buz"}}'

aws dynamodb get-item \
    --endpoint-url http://localhost:8000 \
    --table-name local \
    --key '{ "Id": {"S": "foo"}}'
