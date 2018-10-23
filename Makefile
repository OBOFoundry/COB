# config
MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:
.SECONDARY:

OBO = http://purl.obolibrary.org/obo/

CORE = obo-core.owl
MODULES = generic physical biological human science

PREFIX = 'CORE: http://purl.obolibrary.org/CORE_'

GENERIC_SHEET = https://docs.google.com/spreadsheets/d/e/2PACX-1vRGrxd10VuAmb55RqWEzft8q64mI0Ryr8biOb3K8Sx281Xv0NyRVwhr-Z_0IjFWra8dPmHYeKng6PbS/pub?gid=1709706289&single=true&output=tsv
PHYSICAL_SHEET = https://docs.google.com/spreadsheets/d/e/2PACX-1vRGrxd10VuAmb55RqWEzft8q64mI0Ryr8biOb3K8Sx281Xv0NyRVwhr-Z_0IjFWra8dPmHYeKng6PbS/pub?gid=2144007357&single=true&output=tsv
BIOLOGICAL_SHEET = https://docs.google.com/spreadsheets/d/e/2PACX-1vRGrxd10VuAmb55RqWEzft8q64mI0Ryr8biOb3K8Sx281Xv0NyRVwhr-Z_0IjFWra8dPmHYeKng6PbS/pub?gid=663651851&single=true&output=tsv
HUMAN_SHEET = https://docs.google.com/spreadsheets/d/e/2PACX-1vRGrxd10VuAmb55RqWEzft8q64mI0Ryr8biOb3K8Sx281Xv0NyRVwhr-Z_0IjFWra8dPmHYeKng6PbS/pub?gid=1499631141&single=true&output=tsv
SCIENCE_SHEET = https://docs.google.com/spreadsheets/d/e/2PACX-1vRGrxd10VuAmb55RqWEzft8q64mI0Ryr8biOb3K8Sx281Xv0NyRVwhr-Z_0IjFWra8dPmHYeKng6PbS/pub?gid=1951374411&single=true&output=tsv

core: $(CORE)
$(CORE): $(MODULES)
	$(eval INPUTS := $(foreach I,$(shell ls modules), --input modules/$(I)))
	robot --prefix $(PREFIX) merge $(INPUTS) \
	annotate --ontology-iri $(OBO)obo-core.owl --output $@ 

# ---------- MODULES ---------- #

generic: modules/generic.owl
modules/generic.owl: templates/generic.tsv
	robot --prefix $(PREFIX) template --template $< \
	annotate --ontology-iri $(OBO)obo-core/$@\
	 --output $@

physical: modules/physical.owl
modules/physical.owl: templates/physical.tsv | modules/generic.owl
	robot --prefix $(PREFIX) merge $(foreach I,$|, --input $(I)) \
	template --template $< --ontology-iri $(OBO)obo-core/$@\
	 --output $@

biological: modules/biological.owl
modules/biological.owl: templates/biological.tsv | modules/generic.owl
	robot --prefix $(PREFIX) merge $(foreach I,$|, --input $(I)) \
	template --template $< --ontology-iri $(OBO)obo-core/$@\
	 --output $@

human: modules/human.owl
modules/human.owl: templates/human.tsv | modules/generic.owl modules/biological.owl
	robot --prefix $(PREFIX) merge $(foreach I,$|, --input $(I)) \
	template --template $< --ontology-iri $(OBO)obo-core/$@\
	 --output $@

science: modules/science.owl
modules/science.owl: templates/science.tsv | modules/generic.owl modules/human.owl
	robot --prefix $(PREFIX) merge $(foreach I,$|, --input $(I)) \
	template --template $< --ontology-iri $(OBO)obo-core/$@\
	 --output $@

# ---------- TEMPLATES ---------- #

templates:
	mkdir -p $@

.PHONY: templates/generic.tsv
templates/generic.tsv: | templates
	curl "$(GENERIC_SHEET)" > $@

.PHONY: templates/physical.tsv
templates/physical.tsv:
	curl "$(PHYSICAL_SHEET)" > $@

.PHONY: templates/biological.tsv
templates/biological.tsv:
	curl "$(BIOLOGICAL_SHEET)" > $@

.PHONY: templates/human.tsv
templates/human.tsv:
	curl "$(HUMAN_SHEET)" > $@

.PHONY: templates/science.tsv
templates/science.tsv:
	curl "$(SCIENCE_SHEET)" > $@
