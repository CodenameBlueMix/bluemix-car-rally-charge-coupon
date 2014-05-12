# Licensed under the Apache License. See footer for details.

Q    = require "q"
_    = require "underscore"
nano = require "nano"

utils = require "./utils"

dataCustomer = require "./data-customer"
dataLocation = require "./data-location-austin"

#-------------------------------------------------------------------------------
# contents of the database
#-------------------------------------------------------------------------------
DATABASE_DOCS = []
len = Math.min dataCustomer.length, dataLocation.length

for i in [1...len]
    DATABASE_DOCS.push
        cid:    "#{i}"
        name:   dataCustomer[i]
        city:   dataLocation[i].city
        st:     dataLocation[i].st
        lat:    dataLocation[i].lat
        lon:    dataLocation[i].lon

#-------------------------------------------------------------------------------
# design documentation for our database
#-------------------------------------------------------------------------------
csv_map = (doc) ->
    emit(null, doc)

csv_lists = (head, req) ->
    send 'Customer ID, Name, City, State, Lat, Lon\n'
    while row = getRow()
        arr = []; 
        for k,v of row.value
            arr.push row.value[k]
        send arr.join(',')
        send '\n'
    {}

byID_map = (doc) ->
    {cid, name, city, st, lat, lon} = doc

    return unless cid?
    return unless name?
    return unless city?
    return unless st?
    return unless lat?
    return unless lon?

    emit cid, {name, city, st, lat, lon}

DESIGN_NAME = "customers"
DESIGN_DOC  =
    views:
        byID:
             map: byID_map.toString()
        csv:
            map: csv_map.toString()
    
    lists:
        #coffeescript, your implicit returns can bite me
        csv: "function (head, req) { var arr, row; send('Customer ID, Name, City, State, Lat, Lon\\n'); while (row = getRow()) { arr = []; for (i in row.value) { if (i.indexOf('_') != 0) arr.push(row.value[i]); }; send(arr.join(','));  send('\\n'); }  }"

#-------------------------------------------------------------------------------
# initialize the database, given the full URL
#
# returns a promise of the db when it's done initializing
#-------------------------------------------------------------------------------
exports.init = (url) ->

    # create the DB
    db = new DB url

    # we need some component bits from the full db url
    match = url.match /(.*)\/(.*)/
    unless match?
        return Q.reject new Error "url must have a path component: #{url}"

    [ignore, baseUrl, name] = match

    # try creating the database, in case it doesn't exist
    nanoBase = nano baseUrl

    utils.log "initializing database"
    utils.log "- creating database (if it doesn't already exist)"
    Q.ninvoke nanoBase.db, "create", name

    # check failure, 412 status is ok - db already exists
    .fail (err) ->
        if err.status_code is 412
            utils.log "- database already exists"
            return null

        if err.code is "ECONNREFUSED"
            utils.log "unable to connect to the CouchDB server"
            utils.log "- if running on a PaaS, is the URL to your CouchDB server right?"
            utils.log "- if running locally, have you started a local CouchDB server?"
            utils.log "- you can install a local CouchDB server from here: http://couchdb.apache.org/"
            throw err

        utils.log "- error encountered:"
        utils.log err
        utils.log "- continuing anyway, may be ok"
        return null

    # get all the docs, so we can delete them
    .then (doc) ->
        utils.log "- database created" if doc
        utils.log "- listing all the documents"

        db._dbCall "list"

        # delete all the docs
        .then ([body,headers]) ->
            utils.log "- deleting existing documents" if body.rows.length
            promises = for row in body.rows
                db._dbCall "destroy", row.id, row.value.rev
            Q.all promises

        # create the design doc
        .then ->
            utils.log "- database is now empty"
            utils.log "- inserting design documents"
            db._dbCall "insert", DESIGN_DOC, "_design/#{DESIGN_NAME}"

        # add our documents, ok if fails (already exists)
        .then ->
            utils.log "- inserting sample data"
            db._dbCall "bulk", docs: DATABASE_DOCS

        # return the db object
        .then ->
            utils.log "- database initialization complete"
            return db

#-------------------------------------------------------------------------------
# provides access to the database
#-------------------------------------------------------------------------------
class DB

    #---------------------------------------------------------------------------
    constructor: (url) ->
        @nanoDB = nano url

    #---------------------------------------------------------------------------
    # read an item
    #---------------------------------------------------------------------------
    read: (cid) ->
        unless cid?
            err = new Error "cid cannot be null"
            return Q.reject err

        # get the item
        @_dbCall "view", DESIGN_NAME, "byID", {key: cid}

        # return null if not found
        .fail (err) =>
            return null if err.message is "missing"
            throw err

        # return sanitized version
        .then ([body, headers]) =>
            throw Error "missing" unless body?.rows?.length

            item = @_sanitize body.rows[0].value
            item.cid = cid
            item

    #---------------------------------------------------------------------------
    # search for all items
    #---------------------------------------------------------------------------
    search: (id) ->
        @_dbCall "view", DESIGN_NAME, "byID"

        # return null if not found
        .fail (err) =>
            return null if err.message is "missing"
            throw err

        # return sanitized version
        .then ([body, headers]) =>
            throw Error "missing" unless body?.rows?.length

            items = for row in body.rows
                item = @_sanitize row.value
                item.cid = row.key
                item

            items

    #---------------------------------------------------------------------------
    # wrapper to invoke nano async, returning a promise
    #---------------------------------------------------------------------------
    DEBUG = false  # to enable debug, set DEBUG = 1

    _dbCall: (method, args...) ->
        counter = null

        if DEBUG
            counter = DEBUG++

            argsp = args.map (arg)-> JSON.stringify arg
            argsp = argsp.join ", "
            utils.log "#{counter}:nano(#{method}, #{argsp}) ->"

        p = Q.npost @nanoDB, method, args

        if DEBUG
            p
            .then (result) ->
                result[1] = "...metadata..."
                utils.log "#{counter}:nano success: #{utils.JL result}"
            .fail (err) ->
                utils.log "#{counter}:nano failure: #{err}"

        return p

    #---------------------------------------------------------------------------
    # sanitize an item by white-listing valid properties
    #---------------------------------------------------------------------------
    _sanitize: (obj) ->
        return null unless obj?

        {name, city, st, lat, lon} = obj

        return null unless name?
        return null unless city?
        return null unless st?
        return null unless lat?
        return null unless lon?

        return {name, city, st, lat, lon}

#---------------------------------------------------------------------------
# debug wrapper for a promise logging some diagnostics
#---------------------------------------------------------------------------
debugP = (p, label) ->
    return p if true

    utils.log "#{label} ->"

    p

    .then (result) =>
        utils.log "#{label}: success: #{utils.JL result}"
        result

    .fail (err) =>
        utils.log "#{label}: error: #{err}"
        throw err

    return p

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
