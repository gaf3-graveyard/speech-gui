MACHINE=$(shell uname -m)
ACCOUNT=nandyio
IMAGE=speech-gui
VERSION=0.1
ACCOUNT=nandyio
VOLUMES=-v ${PWD}/www/:/opt/nandy-io/www/ \
		-v ${PWD}/etc/docker.conf:/etc/nginx/conf.d/default.conf
PORT=8371

ifeq ($(MACHINE),armv7l)
BASE=arm32v7/nginx
else
BASE=nginx:1.15.7-alpine
endif

.PHONY: cross build shell run push create update delete create-dev update-dev delete-dev

cross:
	docker run --rm --privileged multiarch/qemu-user-static:register --reset

build:
	docker build . --build-arg BASE=$(BASE) -t $(ACCOUNT)/$(IMAGE):$(VERSION)

shell:
	docker run -it $(VOLUMES) $(ACCOUNT)/$(IMAGE):$(VERSION) sh

run:
	docker run --rm $(VARIABLES) $(VOLUMES) -p 127.0.0.1:$(PORT):80 -h $(IMAGE) $(ACCOUNT)/$(IMAGE):$(VERSION)

start:
	docker run -d --name $(ACCOUNT)-$(IMAGE)-$(VERSION) $(VARIABLES) $(VOLUMES) -p 127.0.0.1:$(PORT):80 -h $(IMAGE) $(ACCOUNT)/$(IMAGE):$(VERSION)

stop:
	docker rm -f $(ACCOUNT)-$(IMAGE)-$(VERSION)

push:
ifeq ($(MACHINE),armv7l)
	docker push $(ACCOUNT)/$(IMAGE):$(VERSION)
else
	echo "Only push armv7l"
endif

install:
	kubectl create -f kubernetes/daemon.yaml

update:
	kubectl replace -f kubernetes/daemon.yaml

remove:
	-kubectl delete -f kubernetes/daemon.yaml

reset: remove install
