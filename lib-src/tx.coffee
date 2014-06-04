# Licensed under the Apache License. See footer for details.

Q = require "q"

utils = require "./utils"
ocm   = require "./open-charge-map"
sgs   = require "./sendgrid-email"

#-------------------------------------------------------------------------------
# returns a new Tx object, ready to have an operation run on it
#
# these objects convert http requests into db actions and generate http responses
#-------------------------------------------------------------------------------
exports.tx = (request, response, customerDB) ->
    new Tx request, response, customerDB

#-------------------------------------------------------------------------------
class Tx

    #---------------------------------------------------------------------------
    constructor: (@request, @response, @customerDB) ->

    #---------------------------------------------------------------------------
    noCustomerDB: ->
        return false if @customerDB?

        utils.log "database not initialized, sending 500 response"
        @response.send 500, "error condition; check server logs"
        return true

    #---------------------------------------------------------------------------
    getCustomers: ->
        return if @noCustomerDB()

        # get items
        @customerDB.search()

        # return item on success
        .then (items) =>
            @response.send items

        .fail (err) => @response.send 500, {err: "#{err}"}
        .done()

    #---------------------------------------------------------------------------
    getCustomer: ->
        return if @noCustomerDB()

        cid = @request.params.cid

        # read item
        @customerDB.read cid

        # send item or 404 response if not found
        .then (item) =>
            if item?
                @response.send item
            else
                @response.send 404

        .fail (err) => @response.send 500, {err: "error reading customer id #{cid}: #{err}"}
        .done()

    #---------------------------------------------------------------------------
    sendEmail: ->
      return if @noCustomerDB()

      cid     = @request.body.cid
      content = @request.body.content
      utils.log "*** tx.sendEmail #{cid} #{content}"
      @customerDB.read cid

      .then (item) =>
        utils.log "*** tx.sendEmail #{item}"
        if item?
          sgs.sendEmail item.email, content
        else
          @response.send 404

      .then (data) =>
        @response.send data

      .fail (err) => @response.send 500, {err: "error sending email to customer id #{cid}: #{err}"}
      .done()

    #---------------------------------------------------------------------------
    getLocations: ->
        lat = @request.params.lat
        lon = @request.params.lon

        ocm.getLocations lat, lon

        .then (data) =>
            @response.send data

        .fail (err) => @response.send 500, {err: "error getting location data for lat: #{lat}, lon: #{lon}; #{err}"}
        .done()

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
