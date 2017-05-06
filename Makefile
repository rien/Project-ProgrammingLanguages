CC=ozc
EXEC=ozengine

SOURCES=$(wildcard *.oz)
OBJECTS=$(SOURCES:.oz=.ozf)

.PHONY: all
all: run

%.ozf: %.oz
	$(CC) -c $<

.PHONY: build
build: $(OBJECTS)

.PHONY: run
run: $(OBJECTS)
	$(EXEC) Main.ozf

.PHONY: clean
clean:
	-rm $(OBJECTS)

.PHONY: binaries
binaries: Player_rbmaerte.ozf Referee_rbmaerte.ozf Board_rbmaerte.ozf Helper_rbmaerte.ozf
	rm binaries_rien_maertens.zip
	zip -j binaries_rien_maertens.zip Player_rbmaerte.ozf Referee_rbmaerte.ozf Board_rbmaerte.ozf Helper_rbmaerte.ozf protocol/README.md
