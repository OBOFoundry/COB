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

core: $(CORE)
$(CORE): $(MODULES)
	$(eval INPUTS := $(foreach I,$(shell ls modules), --input modules/$(I)))
	robot --prefix $(PREFIX) merge $(INPUTS) --output $@ \
	annotate --ontology-iri $(OBO)obo-core.owl
