.PHONY: server develop

all: build

build:
	grunt build

clean:
	grunt clean

install:
	bundle install
	npm install
	./node_modules/.bin/grunt install

server:
	grunt server

develop:
	cd ../choc && make develop
	bower link choc
