PROTOC_INTERFACE_FOLDER := src/protoc_interface

.PHONY: build
build: ## Build the code
	dune build

.PHONY: clean
clean: ## Clean the source tree
	dune clean

.PHONY: format
format: ## Reformat all code
	dune build @fmt --auto-promote

.PHONY: test
test: build
test: ## Run the tests
	dune runtest --force
	$(eval TMP := $(shell mktemp -d))
	protoc --plugin=protoc-gen-ocaml=$(CURDIR)/_build/default/src/protocell/protocell.exe --ocaml_out=$(TMP) test/test.proto
	@echo "\n\nFile contents:\n"
	@find $(TMP) -type f | xargs cat
	@rm -r $(TMP)

.PHONY: release
release: ## Create a new release on Github. Prepare the release for publishing on opam repositories.
	dune-release tag
	dune-release distrib
	dune-release publish
	dune-release opam pkg

.PHONY: generate-spec
generate-spec: 
	$(eval PROTOBUF_INCLUDE := $(shell find /usr -type d -path '*include/google/protobuf' | head -n 1 | xargs dirname | xargs dirname))
	@dune exec -- ocaml-protoc -I $(PROTOBUF_INCLUDE) -int32_type int_t -int64_type int_t -ml_out $(PROTOC_INTERFACE_FOLDER) $(PROTOBUF_INCLUDE)/google/protobuf/compiler/plugin.proto
	@dune exec -- ocaml-protoc -I $(PROTOBUF_INCLUDE) -int32_type int_t -int64_type int_t -ml_out $(PROTOC_INTERFACE_FOLDER) $(PROTOBUF_INCLUDE)/google/protobuf/descriptor.proto

.PHONY: help
help: ## Display this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
