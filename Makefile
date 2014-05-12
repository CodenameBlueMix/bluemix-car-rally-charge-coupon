#default target, tried to reuse an existing install of node.js and bower dependencies
all: clean_cache build deploy

#a target to build a new application from scratch, removing and then re-downloading all dependecies prior to rebuilding
new: clean get build deploy

deploy:
	cf push

build:
	jbuild build

get:
	-jbuild build

clean: clean_cache clean_deps

clean_cache:
	-rm .DS_Store
	-rm -rf www lib tmp
	
clean_deps:  
	-rm -rf node_modules bower_components
