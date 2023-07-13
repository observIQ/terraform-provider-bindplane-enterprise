GOOS ?= $(shell go env GOOS)
GOARCH ?= $(shell go env GOARCH)

ifeq ($(GOOS), windows)
EXT?=.exe
else
EXT?=
endif

ifeq ($(GOARCH), amd64)
GOARCH_FULL?=amd64_v1
else
GOARCH_FULL=$(GOARCH)
endif

.PHONY: provider
provider:
	goreleaser build \
		--skip-validate \
		--single-target \
		--snapshot \
		--rm-dist \
		--config release/goreleaser.yml

.PHONY: test-local
test-local: provider
	rm -rf test/local/providers
	mkdir -p test/local/providers
	cp dist/provider_$(GOOS)_$(GOARCH_FULL)/terraform-provider-bindplane* test/local/providers/terraform-provider-bindplane-enterprise_v0.0.0

.PHONY: test-end-to-end
test-end-to-end: dev-tls provider
	mkdir -p test/integration/providers
	cp dist/provider_$(GOOS)_$(GOARCH_FULL)/terraform-provider-bindplane* test/integration/providers/terraform-provider-bindplane-enterprise_v0.0.0
	bash test/integration/test.sh

dev-tls: test/tls
test/tls:
	mkdir test/tls
	docker run \
		-v ${PWD}/test/scripts/generate-dev-certificates.sh:/generate-dev-certificates.sh \
		-v ${PWD}/test/tls:/tls \
		--entrypoint=/bin/sh \
		alpine/openssl /generate-dev-certificates.sh

.PHONY: clean-dev-tls
clean-dev-tls:
	rm -rf test/tls
