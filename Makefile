# config
MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:
.SECONDARY:

COB = cob.owl
DATE = $(shell date +'%Y-%m-%d')
ROBOT := java -jar build/robot.jar

build:
	mkdir $@

build/robot.jar: build
	curl -Lk -o $@ https://github.com/ontodev/robot/releases/download/v1.4.3/robot.jar

$(COB): cob-edit.owl | build/robot.jar
	$(ROBOT) reason --input $< --reasoner hermit \
	annotate \
	 --ontology-iri "http://purl.obolibrary.org/obo/$@" \
	 --version-iri "http://purl.obolibrary.org/obo/cob/$(DATE)/$@" \
	 --output $@
