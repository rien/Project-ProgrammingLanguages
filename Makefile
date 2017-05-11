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

report.pdf:
	 pandoc -o Report.pdf --latex-engine=xelatex --filter pandoc-include Report.md

.PHONY: report
report:
	when-changed -1 -s -v Report.md 'make report.pdf'
