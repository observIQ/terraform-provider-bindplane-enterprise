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

.PHONY: install-tools
install-tools:
	go install github.com/securego/gosec/v2/cmd/gosec@v2.16.0
	go install github.com/google/addlicense@v1.1.0
	go install github.com/mgechev/revive@v1.3.1
	go install github.com/uw-labs/lichen@v0.1.7
	go install github.com/goreleaser/goreleaser@v1.18.2
	go install golang.org/x/tools/cmd/goimports@latest
	go install github.com/client9/misspell/cmd/misspell@v0.3.4

.PHONY: tidy
tidy:
	go mod tidy

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
test-end-to-end:
	ifndef BINDPLANE_LICENSE
	$(error BINDPLANE_LICENSE is not set)
	endif

	$(MAKE) dev-tls provider

	mkdir -p test/integration/providers
	cp dist/provider_$(GOOS)_$(GOARCH_FULL)/terraform-provider-bindplane* test/integration/providers/terraform-provider-bindplane-enterprise_v0.0.0
	BINDPLANE_LICENSE=${BINDPLANE_LICENSE} test/integration/test.sh

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

.PHONY: ci-check
ci-check: lint misspell check-fmt gosec vet test check-license

.PHONY: lint
lint:
	revive -config .revive.toml -formatter friendly -set_exit_status ./...

.PHONY: misspell
misspell:
	misspell $(ALLDOC)

.PHONY: misspell-fix
misspell-fix:
	misspell -w $(ALLDOC)

.PHONY: check-fmt
check-fmt:
	goimports -d ./ | diff -u /dev/null -

.PHONY: fmt
fmt:
	goimports -w .

.PHONY: gosec
gosec:
	gosec -exclude-generated -exclude-dir internal/tools ./...

.PHONY: vet
vet:
	go vet ./...

.PHONY: test
test:
	go test ./... -cover -race