# Licensed under the Apache License. See footer for details.

fs = require "fs"

# local couchdb server
TODODB_LOCAL   = "http://127.0.0.1:5984/car-rally"

#-------------------------------------------------------------------------------
URL  = require "url"
http = require "http"

Q       = require "q"
_       = require "underscore"
express = require "express"
cfEnv   = require "cf-env"

db      = require "./db"
tx      = require "./tx"
utils   = require "./utils"

# get core data from Cloud Foundry environment

unless process.env.VCAP_SERVICES
    process.env.VCAP_SERVICES = utils.JL require "./vcap-services-local"

if process.env.DATABASE_SERVICE_NAME != undefined and process.env.DATABASE_SERVICE_NAME != ""
    DATABASE_SERVICE = process.env.DATABASE_SERVICE_NAME
else
    # default name of the database service
    DATABASE_SERVICE = "car-rally-db"

cfCore = cfEnv.getCore
    name: utils.PROGRAM

gmapService = cfEnv.getService "gmap"

#-------------------------------------------------------------------------------
# diagnostic message when server exits for any reason
#-------------------------------------------------------------------------------
process.on "exit", (status) ->
    utils.log "process exiting with status #{status}"

#-------------------------------------------------------------------------------
# start the server, returning a promise of the server;
# the promise is resolved when the server starts
#-------------------------------------------------------------------------------
exports.start = (options) ->
    utils.verbose true if options.verbose

    # sometimes you need to dump your ENV vars
    # utils.vlog "process.env #{utils.JL process.env}"

    utils.log "using BlueMix database service: #{DATABASE_SERVICE}"

    # get the url to the couch database
    couchURL = getCouchURL()
    utils.log "using database:  #{sansPassword couchURL}"

    # set up the Google Maps API key
    gmapKey = "IGNORE-FOR-NOW" # setUpGmapKey()
#    utils.log "using gmap key:  #{gmapKey}"

    # initialize the database, async
    db.init couchURL

    # if db init fails, exit
    .fail (err) ->
        utils.log "error initializing database:"
        utils.log err
        utils.log  "server will be operating without database"
        utils.log  "expect other error messages"

        null

    # if db init succeeds, start the server
    .then (customerDB) ->

        # store the db in a global
        options.customerDB = customerDB

        server = new Server options
        server.start()

    # handle exceptions
    .done()

#-------------------------------------------------------------------------------
# class that manages the server
#-------------------------------------------------------------------------------
class Server

    #---------------------------------------------------------------------------
    constructor: (options={}) ->
        options.port    ?= cfCore.port
        options.verbose ?= false

        {@port, @verbose, @customerDB} = options

    #---------------------------------------------------------------------------
    # start the server, returning a promise to itself when started
    #---------------------------------------------------------------------------
    start: ->
        deferred = Q.defer()

        app = express()

        # serve up our html/css/js for the browser
        app.use express.static "www"

        # parse JSON bodies in requests
        app.use express.json()

        # create a transaction object
        app.use (request, response, next) =>
            request.tx = tx.tx request, response, @customerDB
            next()

        # invoke the appropriate transaction
        app.get "/api/customers",           (req, res) => req.tx.getCustomers()
        app.get "/api/customers/:cid",      (req, res) => req.tx.getCustomer()
        app.get "/api/locations/:lat,:lon", (req, res) => req.tx.getLocations()

        # start the server, resolving the promise when started
        utils.log "server starting: #{cfCore.url}"
        app.listen @port, cfCore.bind, =>
            utils.log "server started"

            deferred.resolve @

        return deferred.promise

#-------------------------------------------------------------------------------
# the url to the CouchDB instance
#-------------------------------------------------------------------------------
getCouchURL = ->
    url = cfEnv.getServiceURL DATABASE_SERVICE,
        pathname: "database"
        auth:     ["username", "password"]

    url = url || TODODB_LOCAL

    return url

#-------------------------------------------------------------------------------
# remove the password from a url, for printing
#-------------------------------------------------------------------------------
sansPassword = (url) ->
    url.replace /:\w*@/, ":{password elided}@"

#-------------------------------------------------------------------------------
# get the gmap key, update www/index.html
#-------------------------------------------------------------------------------
setUpGmapKey = ->

    # get the gmap key
    gmapService = cfEnv.getService "gmap"
    unless gmapService?
        utils.logError "no gmap service available"

    gmapKey = gmapService.credentials?.key
    unless gmapKey
        utils.logError "no key in credentials of gmap service: #{gmapService}"

    # rewrite www/index.html
    contents = fs.readFileSync "www/index.html", "utf8"
    contents = contents.replace "%gmapKey%", gmapKey
    fs.writeFileSync "www/index.html", contents

    return gmapKey

#-------------------------------------------------------------------------------
# Copyright IBM Corp. 2014
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#-------------------------------------------------------------------------------
