
watch:
	./node_modules/.bin/supervisor -e 'html|js|coffee|jade' coffee app.coffee

server: watch

sass-watch:
	sass --watch sass:public/stylesheets

sass:
	sass sass:public/stylesheets

develop:
	npm link  
	npm link choc
  cd public/javascripts && ln -s ../../node_modules/choc/choc.browser.js choc.browser.js
