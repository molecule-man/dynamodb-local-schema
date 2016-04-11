#!/bin/bash

set -e

aws --region eu-west-1 dynamodb put-item \
    --endpoint-url http://localhost:8000 \
    --table-name local \
    --item '{ "Id": {"S": "foo"}, "Bar": {"S": "buz"}}'

aws --region eu-west-1 dynamodb get-item \
    --endpoint-url http://localhost:8000 \
    --table-name local \
    --key '{ "Id": {"S": "foo"}}'
