
BIN  := $(shell pwd)/node_modules/.bin
LOG  := $(shell pwd)/log

# cli opts
TAP_OPTS        = --timeout 1 --stderr
SUPERVISOR_OPTS = -q -n exit -e 'js|coffee' -w . \
                  -i '.git,node_modules'
COFFEE_OPTS     = --bare --compile --stdio


default: test

node_modules:
	npm install

all: index.js test.js

clean:
	-rm *.js


# Compilations
%.js: %.coffee | node_modules
	$(BIN)/coffee $(COFFEE_OPTS) < $< > $@


# Testing
test: all | node_modules
	@$(BIN)/tap $(TAP_OPTS) test.js

tdd: all | node_modules
	$(BIN)/supervisor $(SUPERVISOR_OPTS) -x $(MAKE) -- test test.js


.PHONY: clean tdd test

