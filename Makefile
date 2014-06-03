RANDOM := $(shell /bin/bash -c "echo $$RANDOM")
include SETTINGS
#default target, tried to reuse an existing install of node.js and bower dependencies
all: clean_cache build deploy

#execute once before running make
configure: build
	sed 's/$$APP_NAME/$(APP_NAME)/g' manifest.yml.template | \
        sed 's/$$HOST_NAME/$(HOST_NAME)/g' | \
        sed 's/$$DATABASE_SERVICE_NAME/$(DATABASE_SERVICE_NAME)/g' | \
        sed 's/$$OPEN_CHARGE_API_SERVICE_NAME/$(OPEN_CHARGE_API_SERVICE_NAME)/g' \
	> manifest.yml

	cf login
	cf cups $(DATABASE_SERVICE_NAME) -p "url,database,username,password"
	cf cups $(OPEN_CHARGE_API_SERVICE_NAME) -p $(OPEN_CHARGE_API_SERVICE_URL)
	cf push --no-start
	cf se $(APP_NAME) DATABASE_SERVICE_NAME $(DATABASE_SERVICE_NAME)
	cf se $(APP_NAME) OPEN_CHARGE_API_SERVICE_NAME $(OPEN_CHARGE_API_SERVICE_NAME)
	touch configure

#a target to build a new application from scratch, removing and then re-downloading all dependecies prior to rebuilding
new: clean get build deploy

deploy:
	cf push

build:
	jbuild build
	jbuild build

get:
	-jbuild build

clean: clean_cache clean_deps

clean_cache:
	-rm .DS_Store
	-rm -rf www lib tmp
	
clean_deps:  
	-rm -rf node_modules bower_components
