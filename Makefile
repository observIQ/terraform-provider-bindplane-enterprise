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
