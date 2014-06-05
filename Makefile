RANDOM := $(shell /bin/bash -c "echo $$RANDOM")
include SETTINGS
#default target, tried to reuse an existing install of node.js and bower dependencies
all: clean_cache build deploy

install: prereq configure get build deploy

#execute once before running make
configure:
	sed 's/$$APP_NAME/$(APP_NAME)/g' manifest.yml.template | \
        sed 's/$$HOST_NAME/$(HOST_NAME)/g' | \
        sed 's/$$SENDGRID_SERVICE_NAME/$(SENDGRID_SERVICE_NAME)/g' | \
        sed 's/$$DATABASE_SERVICE_NAME/$(DATABASE_SERVICE_NAME)/g' | \
        sed 's/$$OPEN_CHARGE_API_SERVICE_NAME/$(OPEN_CHARGE_API_SERVICE_NAME)/g' \
	> manifest.yml
	cf login
	cf create-service sendgrid free ${SENDGRID_SERVICE_NAME}
	cf cups $(DATABASE_SERVICE_NAME) -p "url,database,username,password"
	cf cups $(OPEN_CHARGE_API_SERVICE_NAME) -p $(OPEN_CHARGE_API_SERVICE_URL)
	#use an empty app contents to create the initial app instance
	mkdir -p tmp; cp package.json tmp
	cf push $(APP_NAME) -n $(HOST_NAME) -p tmp --no-manifest --no-start
	cf bind-service ${APP_NAME} ${SENDGRID_SERVICE_NAME}
	cf se $(APP_NAME) SENDGRID_SERVICE_NAME $(SENDGRID_SERVICE_NAME)
	cf se $(APP_NAME) DATABASE_SERVICE_NAME $(DATABASE_SERVICE_NAME)
	cf se $(APP_NAME) OPEN_CHARGE_API_SERVICE_NAME $(OPEN_CHARGE_API_SERVICE_NAME)
	touch configure

#a target to build a new application from scratch, removing and then re-downloading all dependencies prior to rebuilding
new: clean get build deploy

prereq:
	which node
	which jbuild
	which bower

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
