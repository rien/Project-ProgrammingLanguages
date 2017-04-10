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
