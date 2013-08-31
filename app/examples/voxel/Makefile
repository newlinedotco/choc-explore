js: clean
	coffee -c -o ./js ./coffee

watch-js: clean
	coffee -wc -o ./js ./coffee

browserify:
	browserify js/game.js -o chocgame.js

build: js browserify

watch:
	./node_modules/.bin/supervisor --watch coffee/,node_modules/choc-readable/ --extensions 'coffee|js' --exec 'make' --no-restart-on exit build

.PHONY: test build

clean:
	@rm -fr js/
