
IMG_NAME	= ct-ng
CT_VERSION	= 1.22.0

SRC_DIR		= src
TGT_ARCH	= x86_64-unknown-linux-gnu

DOCKER_BUILD_ENV	= CT_VERSION=$(CT_VERSION) TGT_ARCH=$(TGT_ARCH)
DOCKER_RUN_ENV		= -e TGT_ARCH=$(TGT_ARCH)

all: build extract-toolchain

build:
	env $(DOCKER_BUILD_ENV) \
		docker build --rm -t $(IMG_NAME):$(CT_VERSION) .

latest:
	docker tag $(IMG_NAME):$(CT_VERSION) $(IMG_NAME):latest

shell:
	docker run $(DOCKER_RUN_ENV) -ti $(IMG_NAME):$(CT_VERSION) /bin/bash

fetch-sources:
	rm -rf $(SRC_DIR)
	docker run $(DOCKER_RUN_ENV) $(IMG_NAME):$(CT_VERSION) send-sources | \
		tar xvvf -

fetch-toolchain:
	docker run $(DOCKER_RUN_ENV) $(IMG_NAME):$(CT_VERSION) send-toolchain | \
		gzip --best >ct-ng-$(CT_VERSION)-$(TGT_ARCH).tar.gz

develop:
	env $(DOCKER_BUILD_ENV) CTNG_NO_BUILD=1 \
		docker build --rm -t $(IMG_NAME)-dev . && \
		docker run -ti $(IMG_NAME)-dev /bin/bash
