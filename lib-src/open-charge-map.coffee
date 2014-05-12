# Licensed under the Apache License. See footer for details.

http = require "http"

Q      = require "q"
concat = require "concat-stream"

utils = require "./utils"

API_PARMS = [
    "output=json"
    "maxresults=9"
    "dataproviderid=1"
]

API_URL = "http://api.openchargemap.io/v2/poi/?#{API_PARMS.join '&'}&"

#-------------------------------------------------------------------------------
# return location data from Open Charge Map
#-------------------------------------------------------------------------------
exports.getLocations = (lat, lon) ->

    deferred = Q.defer()

    # scrube the data
    lat = parseFloat "#{lat}"
    lon = parseFloat "#{lon}"

    if isNaN lat
        deferred.reject Error "lat value is not a float"
        return deferred.promise

    if isNaN lon
        deferred.reject Error "lon value is not a float"
        return deferred.promise

    # make the request
    url = "#{API_URL}latitude=#{lat}&longitude=#{lon}"

    http.get url, (response) ->
        writer = concat {encoding: "string"}, (data) ->
            try
                data = JSON.parse data
                data = massageData data
                deferred.resolve data
            catch err
                deferred.reject err

        response.pipe writer

    deferred.promise

#-------------------------------------------------------------------------------
massageData = (data) ->
    i = 1

    for datum in data
        label = i++
        lat   = datum.AddressInfo.Latitude
        lon   = datum.AddressInfo.Longitude

        operator =
            url:   datum?.OperatorInfo?.WebsiteURL || ""
            title: datum?.OperatorInfo?.Title || datum?.AddressInfo?.Title || "unknown"

        if operator.title is "(Unknown Operator)"
            operator.title = datum?.AddressInfo?.Title || "unknown"

        address =
            street: datum?.AddressInfo?.AddressLine1    || "unknown address"
            town:   datum?.AddressInfo?.Town            || "unknown city"
            state:  datum?.AddressInfo?.StateOrProvince || "unknown state"

        {label, lat, lon, operator, address}

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
