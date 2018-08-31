# ----------------------------------------
# Make configuration
# ----------------------------------------

MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:
.SECONDARY:

# ----------------------------------------
# Variables
# ----------------------------------------

OBO=http://purl.obolibrary.org/obo
ONT=obo-core
BASE=$(OBO)/$(ONT)
TODAY=$(shell date +%Y-%m-%d)
SHEET=http://docs.google.com/spreadsheets/d/e/2PACX-1vRGrxd10VuAmb55RqWEzft8q64mI0Ryr8biOb3K8Sx281Xv0NyRVwhr-Z_0IjFWra8dPmHYeKng6PbS/pub?output=tsv

# ----------------------------------------
# ROBOT
# ----------------------------------------

build:
	mkdir -p $@

# Retrieves v1.0.0 of ROBOT to build obo-core
build/robot.jar: | build
	curl -L -o $@ https://github.com/ontodev/robot/releases/download/v1.1.0/robot.jar

ROBOT := java -jar build/robot.jar

# ----------------------------------------
# Top-level targets
# ----------------------------------------

all: $(ONT).owl clean
test: all #sparql_test

# ----------------------------------------
# Main release targets
# ----------------------------------------

# Builds the ontology from the template and imports
$(ONT).owl: $(ONT)-template.ttl build/construct.rq build/catalog-v001.xml | build/robot.jar
	$(ROBOT) query --input $< --query $(word 2,$^) build/imports.ttl \
	&& $(ROBOT) merge --input $< --input build/imports.ttl \
	 annotate --version-iri $(BASE)/$(TODAY)/$@ --output $@

# ----------------------------------------
# Import modules
# ----------------------------------------

# Retrieves the spreadsheet from the Google doc
.PHONY: build/core-terms.tsv
build/core-terms.tsv:
	mkdir -p build && curl -L -o $@ $(SHEET)

# Builds a list of the ontologies to import
build/ontologies.txt: build/core-terms.tsv
	cat $< | \
	tail -n +2 | \
	awk -F'\t' '{print $$1}' | \
	sed '/[^a-zA-Z\d]/d' | \
	sed '/^[[:space:]]*$$/d' | \
	tr A-Z a-z | \
	awk '!seen[$$0]++' > $@

PERL='/^(?!http:\/\/purl\.obolibrary\.org\/obo\/[A-Za-z]*_[0-9]*$$)/ || print'

# Builds a list of the terms to import
build/terms.txt: build/core-terms.tsv
	cat $< | \
	tail -n +2 | \
	awk -F'\t' '{print $$2}' | \
	perl -ne $(PERL) | \
	sed '/^[[:space:]]*$$/d' | \
	awk '!seen[$$0]++' > $@

# Extracts the terms from terms.txt based on list of ontologies
modules: build/ontologies.txt build/terms.txt | build/robot.jar
	cat $< | \
	while read line; \
	do echo "extracting from $$line.owl" &&\
	 $(ROBOT) extract --input-iri $(OBO)/$$line.owl\
	 --method MIREOT --lower-terms $(word 2,$^)\
	 --output-iri $(BASE)/imports/$$line-import.owl\
	 --output imports/$$line-import.owl; \
	done

IMPORTS := $(wildcard imports/*-import.owl)

# Creates a catalog file with all imports
build/catalog-v001.xml: modules
	echo "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>" > $@ && \
	echo "<catalog prefer=\"public\" xmlns=\"urn:oasis:names:tc:entity:xmlns:xml:catalog\">" >> $@ && \
	$(foreach I, $(IMPORTS), echo "	<uri name=\"$(BASE)/imports/$(I)\" uri=\"imports/$(I)\"/>"; echo ""; >> $@) && \
	echo "</catalog>" >> $@

# Creates a construct query to add import statements
build/construct.rq: build/catalog-v001.xml
	echo "PREFIX owl: <http://www.w3.org/2002/07/owl#>" > $@ && \
	echo "CONSTRUCT {" >> $@ && \
	$(foreach I, $(IMPORTS), echo "	?ont owl:imports <$(BASE)/$(I)> . "; echo "";  >> $@) && \
	echo "}" >> $@ && \
	echo "WHERE { ?ont a owl:Ontology }" >> $@

clean: $(ONT).owl
	rm -rf build
