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

OBO = http://purl.obolibrary.org/obo
ONT = obo-core
EDIT = obo-core-edit
BASE = $(OBO)/$(ONT)
TODAY = $(shell date +%Y-%m-%d)
SHEET = http://docs.google.com/spreadsheets/d/e/2PACX-1vRGrxd10VuAmb55RqWEzft8q64mI0Ryr8biOb3K8Sx281Xv0NyRVwhr-Z_0IjFWra8dPmHYeKng6PbS/pub?output=tsv
# Dynamic vars
IMPORTS := $(shell cat build/ontologies.txt | awk '{print $$1}')
MODS := $(shell cat build/ontologies.txt | awk '{print $$1}' | tr A-Z a-z)



# ----------------------------------------
# ROBOT
# ----------------------------------------

# build:
	# mkdir -p $@

# Retrieves latest version of ROBOT to build obo-core
# build/robot.jar: | build
	# curl -L -o $@ \
	# https://build.berkeleybop.org/job/robot/lastSuccessfulBuild/artifact/bin/robot.jar

# Currently using a rogue version of ROBOT
ROBOT := java -jar build/robot.jar

# ----------------------------------------
# Top-level targets
# ----------------------------------------

all: $(ONT).owl
#test: all sparql_test

# ----------------------------------------
# Main release targets
# ----------------------------------------

# Builds the ontology from the template and imports
.PHONY: $(ONT).owl
$(ONT).owl: $(EDIT).owl
	@echo "Generating obo-core.owl" && \
	$(ROBOT) merge --input $< \
	 annotate --version-iri $(BASE)/$(TODAY)/$@ --output $@

# Creates an edit file with import statements
.PHONY: $(EDIT).owl
$(EDIT).owl: build/construct.rq catalog-v001.xml build/catalog-v001.xml | build/robot.jar
	@echo "Generating $(EDIT).owl" && \
	$(ROBOT) query --input $(ONT)-template.ttl --query $< build/imports.ttl && \
	$(ROBOT) convert --input build/imports.ttl --format ofn --output $@

# Creates a construct query to add import statements
.PHONY: build/construct.rq
build/construct.rq:
	$(eval IMP_FILES := $(wildcard imports/*-import.owl))
	$(eval QUERY := $(foreach I,$(IMP_FILES), " ?ont owl:imports <$(BASE)/$(I)> . "))
	@echo "PREFIX owl: <http://www.w3.org/2002/07/owl#>" > $@ && \
	echo "CONSTRUCT {" >> $@ && \
	echo $(QUERY) >> $@ && \
	echo "}" >> $@ && \
	echo "WHERE { ?ont a owl:Ontology }" >> $@

# Creates a catalog file with all imports
.PHONY: catalog-v001.xml
catalog-v001.xml:
	$(eval IMP_FILES := $(wildcard imports/*-import.owl))
	$(eval CATALOG := $(foreach I,$(IMP_FILES), " <uri name=\"$(BASE)/$(I)\" uri=\"$(I)\"/>"))
	@echo "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>" > $@ && \
	echo "<catalog prefer=\"public\" xmlns=\"urn:oasis:names:tc:entity:xmlns:xml:catalog\">"\
	 >> $@ && \
	echo $(CATALOG) >> $@ && \
	echo "</catalog>" >> $@

# Creates a catalog file with all imports in the build dir
.PHONY: build/catalog-v001.xml
build/catalog-v001.xml: $(MODS) full_imports
	$(eval IMP_FILES := $(wildcard imports/*-import.owl))
	$(eval BUILD_CATALOG := $(foreach I,$(IMP_FILES), " <uri name=\"$(BASE)/$(I)\" uri=\"../$(I)\"/>"))
	@echo "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>" > $@ && \
	echo "<catalog prefer=\"public\" xmlns=\"urn:oasis:names:tc:entity:xmlns:xml:catalog\">"\
	 >> $@ && \
	echo $(BUILD_CATALOG) >> $@ && \
	echo "</catalog>" >> $@

# ----------------------------------------
# Dynamic Imports
# ----------------------------------------

imports: build/core-terms.tsv build/ontologies.txt $(IMPORTS) $(MODS) full_imports

# Retrieves the spreadsheet from the Google doc and regenerates imports folder
.PHONY: build/core-terms.tsv
build/core-terms.tsv:
	mkdir -p build && curl -L -o $@ $(SHEET) && rm -rf imports && mkdir imports

# Builds a list of the ontologies to import
# Ignores BFO, and RO as we import larger parts of these
# We import all annotation props from IAO, but need add. classes
.PHONY: build/ontologies.txt
build/ontologies.txt: build/core-terms.tsv
	@cat $< | \
	tail -n +2 | \
	awk -F'\t' '{print $$1}' | \
	sed '/[^a-zA-Z\d]/d' | \
	sed '/^BFO$$/d' | sed '/^RO$$/d' | \
	sed '/^[[:space:]]*$$/d' | \
	awk '!seen[$$0]++' > $@

# Builds a list of the terms to import and creates a new import folder
.PHONY: $(IMPORTS)
$(IMPORTS): build/core-terms.tsv build/ontologies.txt
	@cat $< | \
	tail -n +2 | \
	awk -F'\t' '{print $$2}' | \
	perl -ne '/^(?!http:\/\/purl\.obolibrary\.org\/obo\/$@*_[0-9]*$$)/i || print' | \
	sed '/^[[:space:]]*$$/d' | \
	awk '!seen[$$0]++' > build/$@-terms.txt

# Extracts the terms from terms.txt based on list of ontologies
# Use "lite" versions: GO, ChEBI, DO, DrOn, NCBITaxon, UPHENO
# (Rogue version of ROBOT can handle zip & gzip files)
.PHONY: $(MODS)
$(MODS): $(IMPORTS) | build/robot.jar
	@IRI=$(OBO)/$@.owl && \
	if [ $@ = go ]; then\
		IRI=$(OBO)/$@/subsets/goslim_generic.owl; \
	elif [ $@ = chebi ]; then\
		IRI=ftp://ftp.ebi.ac.uk/pub/databases/chebi/ontology/chebi_lite.owl.gz; \
	elif [ $@ = dron ]; then\
		IRI=http://purl.obolibrary.org/obo/dron/dron-upper.owl; \
	elif [ $@ = ncbitaxon ]; then\
		IRI=$(OBO)/$@/subsets/taxslim.owl; \
	elif [ $@ = upheno ]; then\
		IRI=$(OBO)/upheno/imports/extra.owl; \
	fi && \
	echo "Extracting from $$IRI" && \
	$(ROBOT) extract --input-iri $$IRI\
	 --method MIREOT --lower-terms build/$@-terms.txt \
	annotate --ontology-iri $(BASE)/imports/$@-import.owl\
	 --output imports/$@-import.owl

# ----------------------------------------
# Static Imports
# ----------------------------------------

# Imports all BFO classes, all RO object properties, and all IAO annotation properties
full_imports: imports/bfo-cls-import.owl imports/ro-op-import.owl imports/iao-ap-import.owl

.PHONY: imports/bfo-cls-import.owl
imports/bfo-cls-import.owl: | build/robot.jar
	$(ROBOT) filter --input-iri $(OBO)/bfo.owl --select classes\
	 --ontology-iri $(BASE)/$@ --output $@

.PHONY: imports/ro-op-import.owl
imports/ro-op-import.owl: | build/robot.jar
	$(ROBOT) filter --input-iri $(OBO)/ro.owl --select object-properties\
	 --ontology-iri $(BASE)/$@ --output $@

.PHONY: imports/iao-ap-import.owl
imports/iao-ap-import.owl: | build/robot.jar
	$(ROBOT) filter --input-iri $(OBO)/iao.owl --select annotation-properties\
	 --ontology-iri $(BASE)/$@ --output $@

# ----------------------------------------
# Post-build tasks
# ----------------------------------------

clean:
	cd build && rm -f *.tsv *.txt *.rq *.xml *.ttl
