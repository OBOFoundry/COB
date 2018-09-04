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

OBO 		 = http://purl.obolibrary.org/obo
ONT 		 = obo-core
BASE 		 = $(OBO)/$(ONT)
TODAY 		 = $(shell date +%Y-%m-%d)
SHEET 		 = http://docs.google.com/spreadsheets/d/e/2PACX-1vRGrxd10VuAmb55RqWE\
			   zft8q64mI0Ryr8biOb3K8Sx281Xv0NyRVwhr-Z_0IjFWra8dPmHYeKng6PbS/pub?output=tsv
# Dynamic vars
IMPORTS 	:= $(shell cat build/ontologies.txt | awk '{print $$1}')
MODS 		:= $(shell cat build/ontologies.txt | awk '{print $$1}' | tr A-Z a-z)
IMPORT_FILES:= $(wildcard imports/*-import.owl)
CATALOG 	:= $(foreach I,$(IMPORT_FILES), " <uri name=\"$(BASE)/$(I)\" uri=\"../$(I)\"/>")
QUERY 		:= $(foreach I,$(IMPORT_FILES), " ?ont owl:imports <$(BASE)/$(I)> . ")

# ----------------------------------------
# ROBOT
# ----------------------------------------

build:
	mkdir -p $@

# Retrieves latest version of ROBOT to build obo-core
build/robot.jar: | build
	curl -L -o $@ \
	https://build.berkeleybop.org/job/robot/lastSuccessfulBuild/artifact/bin/robot.jar

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

# Creates a construct query to add import statements
build/construct.rq: build/catalog-v001.xml
	echo "PREFIX owl: <http://www.w3.org/2002/07/owl#>" > $@ && \
	echo "CONSTRUCT {" >> $@ && \
	echo $(QUERY) >> $@ && \
	echo "}" >> $@ && \
	echo "WHERE { ?ont a owl:Ontology }" >> $@

# Creates a catalog file with all imports
build/catalog-v001.xml: modules full_imports
	echo "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>" > $@ && \
	echo "<catalog prefer=\"public\" xmlns=\"urn:oasis:names:tc:entity:xmlns:xml:catalog\">"\
	 >> $@ && \
	echo $(CATALOG) >> $@ && \
	echo "</catalog>" >> $@

# ----------------------------------------
# Dynamic Imports
# ----------------------------------------

# Retrieves the spreadsheet from the Google doc
.PHONY: build/core-terms.tsv
build/core-terms.tsv:
	mkdir -p build && curl -L -o $@ $(SHEET)

# Builds a list of the ontologies to import
# Ignores BFO, RO, and IAO as we import larger parts of these
build/ontologies.txt: build/core-terms.tsv
	cat $< | \
	tail -n +2 | \
	awk -F'\t' '{print $$1}' | \
	sed '/[^a-zA-Z\d]/d' | \
	sed '/^BFO$$/d' | sed '/^RO$$/d' | sed '/^IAO$$/d' | \
	sed '/^[[:space:]]*$$/d' | \
	awk '!seen[$$0]++' > $@

# Builds a list of the terms to import
terms: $(IMPORTS)
$(IMPORTS): build/core-terms.tsv build/ontologies.txt
	cat $< | \
	tail -n +2 | \
	awk -F'\t' '{print $$2}' | \
	perl -ne '/^(?!http:\/\/purl\.obolibrary\.org\/obo\/$@*_[0-9]*$$)/i || print' | \
	sed '/^[[:space:]]*$$/d' | \
	awk '!seen[$$0]++' > build/$@-terms.txt

# Extracts the terms from terms.txt based on list of ontologies
modules: $(MODS)
$(MODS): terms | build/robot.jar
	$(ROBOT) extract --input-iri $(OBO)/$@.owl\
	 --method BOT --term-file build/$@-terms.txt\
	 --output-iri $(BASE)/imports/$@-import.owl\
	 --output imports/$@-import.owl

# ----------------------------------------
# Static Imports
# ----------------------------------------

# Imports all BFO classes, all RO object properties, and all IAO annotation properties
full_imports: imports/bfo-import.owl imports/ro-import.owl imports/iao-import.owl

.PHONY: imports/bfo-import.owl
imports/bfo-import.owl: | build/robot.jar
	$(ROBOT) filter --input-iri $(OBO)/bfo.owl --select classes\
	 --ontology-iri $(BASE)/imports/$@ --output $@

.PHONY: imports/ro-import.owl
imports/ro-import.owl: | build/robot.jar
	$(ROBOT) filter --input-iri $(OBO)/ro.owl --select object-properties\
	 --ontology-iri $(BASE)/imports/$@ --output $@

.PHONY: imports/iao-import.owl
imports/iao-import.owl: | build/robot.jar
	$(ROBOT) filter --input-iri $(OBO)/iao.owl --select annotation-properties\
	 --ontology-iri $(BASE)/imports/$@ --output $@

# ----------------------------------------
# Post-build tasks
# ----------------------------------------

clean: $(ONT).owl
	rm -rf build
