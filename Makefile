DOCKER := docker
DC := docker-compose
BUILD_FLAGS := -ldflags '-s'
PACKAGES := . ./pkg/...
ARTIFACT = dbmate
IMAGE_NAME = $(REGISTRY)/red-$(ARTIFACT):$(TAG)

.PHONY: all
all: dep install test lint build

.PHONY: dep
dep:
	dep ensure -vendor-only

.PHONY: install
install:
	go install -v $(PACKAGES)

.PHONY: test
test:
	go test -v $(PACKAGES)

.PHONY: lint
lint:
	gometalinter.v2 $(PACKAGES)

.PHONY: wait
wait:
	dbmate -e MYSQL_URL wait
	dbmate -e POSTGRESQL_URL wait

.PHONY: clean
clean:
	rm -rf dist

.PHONY: build
build: clean
	GOARCH=amd64 go build $(BUILD_FLAGS) -o dist/dbmate-linux-amd64 .
	# musl target does not support sqlite
	GOARCH=amd64 CGO_ENABLED=0 go build $(BUILD_FLAGS) -o dist/dbmate-linux-musl-amd64 .

.PHONY: docker
docker:
	$(DC) pull
	$(DC) build
	$(DC) run --rm dbmate make

.PHONY: image
image: TAG ?= latest
image:
	$(DOCKER) build -t dbmate:build -f Dockerfile.build .
	$(DOCKER) create --name dbmate-build dbmate:build
	$(DOCKER) cp dbmate-build:/go/src/github.com/amacneil/dbmate/dist/dbmate-linux-musl-amd64 ./dbmate-linux-amd64
	$(DOCKER) rm -f dbmate-build
	$(DOCKER) build -t $(IMAGE_NAME) .
	rm ./dbmate-linux-amd64

.PHONY: image-and-push
image-and-push: image
	$$(aws ecr get-login --region us-east-1 --no-include-email)
	$(DOCKER) push $(IMAGE_NAME)
