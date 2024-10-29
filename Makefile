IMAGE_NAME := $(shell basename $(CURDIR))
CONTAINER_ID := $(shell docker ps --filter "ancestor=$(IMAGE_NAME)" --format "{{.ID}}")
DOCKER_EXEC := docker exec -it $(CONTAINER_ID)

# ==================================================================================== #
# HELPERS
# ==================================================================================== #

## help: print this help message
.PHONY: help
help:
	@echo 'Usage:'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' |  sed -e 's/^/ /'

.PHONY: confirm
confirm:
	@echo -n 'Are you sure? [y/N] ' && read ans && [ $${ans:-N} = y ]

.PHONY: no-dirty
no-dirty:
	git diff --exit-code


# ==================================================================================== #
# QUALITY CONTROL
# ==================================================================================== #

## tidy: format code and tidy project
.PHONY: tidy
tidy:
	$(DOCKER_EXEC) npm lint

## audit: run quality control checks
.PHONY: audit
audit:
	$(DOCKER_EXEC) npm audit

## test: run all tests
.PHONY: test
test:
	$(DOCKER_EXEC) npm test

## test/cover: generate coverage report
.PHONY: test/cover
test/cover:
	$(DOCKER_EXEC) npm test -- --coverage


# ==================================================================================== #
# DEVELOPMENT
# ==================================================================================== #

## build: build the container
.PHONY: build
build:
	docker build -t $(IMAGE_NAME) .

## ssh: shh into the running container
.PHONY: ssh
ssh:
	$(DOCKER_EXEC) /bin/sh

## open: open app in the browser
.PHONY: open
open:
	@PORT=$$(docker port $(CONTAINER_ID) | grep -Eo '[0-9]+$$' | head -n 1) \
	&& [ -n "$$PORT" ] && open http://localhost:$$PORT || echo "Container is not running or has no exposed port"

## run: run the container
.PHONY: run
run: build
	docker run --rm -itPv $$(pwd):/app $(IMAGE_NAME)


# ==================================================================================== #
# OPERATIONS
# ==================================================================================== #

## push: push changes to the remote Git repository
.PHONY: push
push: tidy audit no-dirty
	git push
