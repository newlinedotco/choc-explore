.PHONY: server develop

install:
	bundle install
	npm install
	./node_modules/.bin/grunt install

server:
	grunt server

develop:
	cd ../choc && make develop
	bower link choc
