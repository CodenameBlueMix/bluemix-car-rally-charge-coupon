# Licensed under the Apache License. See footer for details.

Q      = require "q"
expect = require "expect.js"

dbLib = require "../lib/db"

dbURL = "http://127.0.0.1:5984/car-rally"
db    = null

log = (message) -> console.log "test-db: #{message}"

process.on "uncaughtException", (err) ->
    log err.stack
    process.exit 1

#-------------------------------------------------------------------------------
describe "db", ->

    before (done) ->
        dbLib.init dbURL

        .then (db_) ->
            db = db_

        .fail (err) -> expect().fail("failed: #{err}")
        .fin -> done()
        .done()

    #---------------------------------------------------------------------------
    it "should find the id 1", (done) ->
        db.find "1"

        .then (item) ->
            log JSON.stringify item
            expect(item).to.be.ok()

        .fail (err) -> expect().fail("failed: #{err}")
        .fin -> done()
        .done()

    #---------------------------------------------------------------------------
    it "should find id 2", (done) ->
        db.find "2"

        .then (item) ->
            expect(item).to.be.ok()

        .fail (err) -> expect().fail("failed: #{err}")
        .fin -> done()
        .done()

    #---------------------------------------------------------------------------
    it "should find id 3", (done) ->
        db.find "3"

        .then (item) ->
            expect(item).to.be.ok()

        .fail (err) -> expect().fail("failed: #{err}")
        .fin -> done()
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
