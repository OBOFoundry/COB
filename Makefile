# config
MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:
.SECONDARY:

OBO = http://purl.obolibrary.org/obo

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


# ---------- RELEASE ---------- #
core.owl: core-edit.owl
	robot merge -i $< -o $@

%.json: %.owl
	robot convert -i $< -o $@

INVERSE_NEST_RELATION = $(OBO)/CORE_0003000
OGSTYLE = obograph-style.json
OGARGS = -s $(OGSTYLE)
core.dot: core.json $(OGSTYLE)
	og2dot.js $(OGARGS) $< > $@.tmp && mv $@.tmp $@

# nest has-part
core-n.dot: core.json $(OGSTYLE)
	og2dot.js $(OGARGS) -I $(INVERSE_NEST_RELATION) $< > $@.tmp && mv $@.tmp $@

%.png: %.dot
	dot $< -Grankdir=BT -Tpng -o $@.tmp && mv $@.tmp $@

# ---------- ALIGNMENT ---------- #
# Currentlh this requires installing some tools - I will set up a docker for running these...

XONTS = ro sio biotop bfoc mesh chebi blmod common_core
all_matches: $(patsubst %, matches/matches-%.tsv, $(XONTS))

matches/matches-%.tsv: manual-core.owl
	rdfmatch -d rdf_matcher -G imports/matches-$*.owl --predicate skos:exactMatch --prefix CORE -f tsv -l -A ~/repos/onto-mirror/void.ttl -i prefixes.ttl -i $< -i $* new_match > $@.tmp &&   cut -f1-4 $@.tmp | sort -u > $@

# match to wikidata
matches/wd-closematches.ttl: manual-core.owl
	wd-ontomatch -d ontomatcher -i $< -a wikidata_ontomatcher:cached_db_file=$@ -e match_classes

matches/wd-align.tsv: manual-core.owl matches/wd-closematches.ttl
	rdfmatch -d rdf_matcher -G imports/matches-wd.owl --predicate skos:closeMatch --prefix CORE -f tsv -l -A ~/repos/onto-mirror/void.ttl -i prefixes.ttl -i $< -i wd-closematches.ttl exact > $@.tmp &&  cut -f1-9,11,15-19 $@.tmp > $@


usage.tsv:
	pl2sparql -f tsv -l -e -i core.owl -c util/core-usage.pro core_term_usage  > $@
