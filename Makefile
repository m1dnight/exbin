DOCKER_TAG := $(shell grep 'version:' mix.exs | sed -e 's/.*version: "\(.*\)",/\1/')
DOCKER_IMG := m1dnight/exbin

.PHONY: build

build:
	docker build -t $(DOCKER_IMG):$(DOCKER_TAG) .
	docker build -t $(DOCKER_IMG):latest .

build-fresh:
	docker build --no-cache -t $(DOCKER_IMG):$(DOCKER_TAG) .
	docker build --no-cache -t $(DOCKER_IMG):latest .

push: 
	docker push $(DOCKER_IMG):$(DOCKER_TAG)
	docker push $(DOCKER_IMG):latest