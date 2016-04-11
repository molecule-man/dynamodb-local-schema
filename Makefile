DYNAMO_IMAGE = molecularman/alpine-dynamodb-local:1.0.0
IMAGE = molecularman/dynamodb-local-schema
VERSION = 1.0.0
TEST_CNT_NAME=dynamodbschema

ifdef CIRCLE_BUILD_NUM
	BUILD_NUM = ${CIRCLE_BUILD_NUM}
else
	BUILD_NUM = $(shell git rev-parse --short HEAD)
endif

build:
	./build.sh $(IMAGE):$(VERSION) $(DYNAMO_IMAGE)
	docker tag $(IMAGE):$(VERSION) $(IMAGE):$(VERSION)-$(BUILD_NUM)

launch: stop
	docker create --name $(TEST_CNT_NAME) $(IMAGE):$(VERSION)
	docker run -d --name adl -p 8000:8000 --volumes-from $(TEST_CNT_NAME) $(DYNAMO_IMAGE)

test: launch
	sleep 1
	./test.sh

stop:
	docker kill adl && docker rm -f adl || true
	docker rm -f $(TEST_CNT_NAME) || true

push:
	docker tag $(IMAGE):$(VERSION) $(IMAGE):latest
	docker push $(IMAGE):$(VERSION)
	docker push $(IMAGE):$(VERSION)-$(BUILD_NUM)
	docker push $(IMAGE):latest
