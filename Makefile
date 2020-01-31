# config
MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:
.SECONDARY:

ROBOT := java -jar build/robot.jar

build/robot.jar:
	curl -Lk -o $@ https://github.com/ontodev/robot/releases/download/v1.4.3/robot.jar

OBO = http://purl.obolibrary.org/obo/

COB = cob.owl
MODULES = generic physical biological human science

PREFIX = 'COB: http://purl.obolibrary.org/COB_'

GENERIC_SHEET = https://docs.google.com/spreadsheets/d/e/2PACX-1vRGrxd10VuAmb55RqWEzft8q64mI0Ryr8biOb3K8Sx281Xv0NyRVwhr-Z_0IjFWra8dPmHYeKng6PbS/pub?gid=1709706289&single=true&output=tsv
PHYSICAL_SHEET = https://docs.google.com/spreadsheets/d/e/2PACX-1vRGrxd10VuAmb55RqWEzft8q64mI0Ryr8biOb3K8Sx281Xv0NyRVwhr-Z_0IjFWra8dPmHYeKng6PbS/pub?gid=2144007357&single=true&output=tsv
BIOLOGICAL_SHEET = https://docs.google.com/spreadsheets/d/e/2PACX-1vRGrxd10VuAmb55RqWEzft8q64mI0Ryr8biOb3K8Sx281Xv0NyRVwhr-Z_0IjFWra8dPmHYeKng6PbS/pub?gid=663651851&single=true&output=tsv
HUMAN_SHEET = https://docs.google.com/spreadsheets/d/e/2PACX-1vRGrxd10VuAmb55RqWEzft8q64mI0Ryr8biOb3K8Sx281Xv0NyRVwhr-Z_0IjFWra8dPmHYeKng6PbS/pub?gid=1499631141&single=true&output=tsv
SCIENCE_SHEET = https://docs.google.com/spreadsheets/d/e/2PACX-1vRGrxd10VuAmb55RqWEzft8q64mI0Ryr8biOb3K8Sx281Xv0NyRVwhr-Z_0IjFWra8dPmHYeKng6PbS/pub?gid=1951374411&single=true&output=tsv

$(COB): cob-edit.owl | build/robot.jar
	$(ROBOT) reason \
	 --input $< \
	annotate \
	 --ontology-iri "$(OBO)$(COB)" \
	 --output $@

previous-$(COB): $(MODULES) | build/robot.jar
	$(eval INPUTS := $(foreach I,$(shell ls modules), --input modules/$(I)))
	$(ROBOT) --prefix $(PREFIX) merge $(INPUTS) --output $@ 

# ---------- MODULES ---------- #

generic: modules/generic.owl
modules/generic.owl: templates/generic.tsv | build/robot.jar
	$(ROBOT) --prefix $(PREFIX) template --template $< \
	annotate --ontology-iri $(OBO)cob/$@\
	 --output $@

physical: modules/physical.owl
modules/physical.owl: templates/physical.tsv | modules/generic.owl build/robot.jar
	$(ROBOT) --prefix $(PREFIX) merge $(foreach I,$|, --input $(I)) \
	template --template $< --ontology-iri $(OBO)cob/$@\
	 --output $@

biological: modules/biological.owl
modules/biological.owl: templates/biological.tsv | modules/generic.owl build/robot.jar
	$(ROBOT) --prefix $(PREFIX) merge $(foreach I,$|, --input $(I)) \
	template --template $< --ontology-iri $(OBO)cob/$@\
	 --output $@

human: modules/human.owl
modules/human.owl: templates/human.tsv | modules/generic.owl modules/biological.owl build/robot.jar
	$(ROBOT) --prefix $(PREFIX) merge $(foreach I,$|, --input $(I)) \
	template --template $< --ontology-iri $(OBO)cob/$@\
	 --output $@

science: modules/science.owl
modules/science.owl: templates/science.tsv | modules/generic.owl modules/human.owl build/robot.jar
	$(ROBOT) --prefix $(PREFIX) merge $(foreach I,$|, --input $(I)) \
	template --template $< --ontology-iri $(OBO)cob/$@\
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


# ---------- TESTS & REPORTS ---------- #

build:
	mkdir -p $@

# Files to create pseudo-core
build/bfo-classes.owl: build
	curl -Lk -o $@ http://purl.obolibrary.org/obo/bfo/classes.owl

build/ro-core.owl: build
	curl -Lk -o $@ http://purl.obolibrary.org/obo/ro/core.owl

build/pseudo-core.owl: build/bfo-classes.owl build/ro-core.owl | build/robot.jar
	$(ROBOT) merge \
	 --input $< \
	 --input $(word 2,$^) \
	annotate \
	 --remove-annotations \
	 --ontology-iri "$(OBO)obo-core/pseudo-core.owl" \
	 --output $@

build/pseudo-terms.csv:  util/get-terms.rq | build/robot.jar
	$(ROBOT) query \
	 --input build/pseudo-core.owl \
	 --query $(word 2,$^) $@

build/core-terms.csv: cob.owl util/get-terms.rq | build/robot.jar
	$(ROBOT) query \
	 --input $< \
	 --query $(word 2,$^) $@

build/obi-terms.csv: util/get-terms.rq | build/robot.jar
	$(ROBOT) query \
	 --input-iri $(OBO)obi.owl \
	 --query $< $@

diff: build/pseudo-terms.csv build/core-terms.csv build/obi-terms.csv
	./util/compare-terms.py $^ build

# ---------- ALIGNMENT ---------- #
# Currentlh this requires installing some tools - I will set up a docker for running these...

XONTS = ro sio biotop bfoc mesh chebi blmod common_core
all_matches: $(patsubst %, matches/matches-%.tsv, $(XONTS))

matches/matches-%.tsv: manual-core.owl
	rdfmatch -d rdf_matcher -G imports/matches-$*.owl --predicate skos:exactMatch --prefix COB -f tsv -l -A ~/repos/onto-mirror/void.ttl -i prefixes.ttl -i $< -i $* new_match > $@.tmp &&   cut -f1-4 $@.tmp | sort -u > $@

# match to wikidata
matches/wd-closematches.ttl: manual-core.owl
	wd-ontomatch -d ontomatcher -i $< -a wikidata_ontomatcher:cached_db_file=$@ -e match_classes

matches/wd-align.tsv: manual-core.owl matches/wd-closematches.ttl
	rdfmatch -d rdf_matcher -G imports/matches-wd.owl --predicate skos:closeMatch --prefix COB -f tsv -l -A ~/repos/onto-mirror/void.ttl -i prefixes.ttl -i $< -i wd-closematches.ttl exact > $@.tmp &&  cut -f1-9,11,15-19 $@.tmp > $@
