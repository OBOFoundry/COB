### Configuration
#
# These are standard options to make Make sane:
# <http://clarkgrubb.com/makefile-style-guide#toc2>
MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:
.SECONDARY:

DATE = $(shell date +'%Y-%m-%d')
ROBOT := java -jar build/robot.jar

all: build/report.tsv cob.owl

build:
	mkdir $@

build/robot.jar: | build
	curl -L -o $@ https://github.com/ontodev/robot/releases/download/v1.5.0/robot.jar

build/report.tsv: cob-edit.owl | build/robot.jar
	$(ROBOT) report \
	--input $^ \
	--labels true \
	--output $@

cob.owl: cob-edit.owl | build/robot.jar
	$(ROBOT) reason --input $< --reasoner hermit \
	annotate \
	--ontology-iri "http://purl.obolibrary.org/obo/$@" \
	--version-iri "http://purl.obolibrary.org/obo/cob/$(DATE)/$@" \
	--output $@

COB_COMPLIANT = pato obi ro

itest: $(patsubst %, build/reasoned-%.owl, $(COB_COMPLIANT))

build/source-%.owl:
	curl -L -s $(OBO)/$*.owl > $@.tmp && mv $@.tmp $@
.PRECIOUS: build/source-%.owl

build/merged-%.owl: build/source-%.owl cob.owl cob-to-external.owl
	robot merge -i $< -i cob.owl -i cob-to-external.owl --collapse-import-closure true -o $@
.PRECIOUS: build/merged-%.owl

build/reasoned-%.owl: build/merged-%.owl
	touch $@.RUN && robot reason --reasoner ELK -i $< -o $@ && rm $@.RUN
