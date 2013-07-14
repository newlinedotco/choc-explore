.PHONY: server develop

server:
	grunt server

develop:
	pushd ../choc && npm link
	npm link
	npm link choc
	cd app/scripts && ln -s ../../node_modules/choc/choc.browser.js choc.browser.js
