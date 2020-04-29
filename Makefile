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

all: test build/report.tsv cob.owl

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

# base file is main cob plus linking axioms
cob-base.owl: cob.owl cob-to-external.owl
	robot merge $(patsubst %, -i %, $^) -o $@

# TSV export (may depend on dev version of robot export)
cob.tsv: cob.owl
	robot export -i $< -c "ID|ID [label]|definition|subClassOf [ID]|subClassOf [label]" -e $@

# this is a really hacky way to do this, replace with robot report?
cob-to-external.ttl: cob-to-external.tsv
	./util/tsv2rdf.pl $< > $@.tmp && mv $@.tmp $@
cob-to-external.owl: cob-to-external.ttl
	robot convert -i $< -o $@

# totally as-hoc list for now
COB_COMPLIANT = pato go cl uberon po uberon+cl ro envo chebi ogms doid hp mp mondo obi

itest: $(patsubst %, build/reasoned-%.owl, $(COB_COMPLIANT))

build/source-%.owl:
	curl -L -s $(OBO)/$*.owl > $@.tmp && mv $@.tmp $@
.PRECIOUS: build/source-%.owl

# TODO: we should use the registry for this
build/source-go.owl:
	curl -L -s $(OBO)/go/go-base.owl > $@.tmp && mv $@.tmp $@
build/source-uberon.owl:
	curl -L -s $(OBO)/uberon/uberon-base.owl > $@.tmp && mv $@.tmp $@
build/source-cl.owl:
	curl -L -s $(OBO)/cl/cl-base.owl > $@.tmp && mv $@.tmp $@
build/source-envo.owl:
	curl -L -s $(OBO)/envo/envo-base.owl > $@.tmp && mv $@.tmp $@

build/source-uberon+cl.owl: build/source-cl.owl build/source-uberon.owl
	robot merge $(patsubst %, -i %, $^) -o $@

build/merged-%.owl: build/source-%.owl cob.owl cob-to-external.owl
	robot merge -i $< -i cob.owl -i cob-to-external.owl --collapse-import-closure true -o $@
.PRECIOUS: build/merged-%.owl

build/reasoned-%.owl: build/merged-%.owl
	touch $@.RUN && robot reason --reasoner ELK -i $< -o $@ && rm $@.RUN
