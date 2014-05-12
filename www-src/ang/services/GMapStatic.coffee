# Licensed under the Apache License. See footer for details.

#-------------------------------------------------------------------------------
# for more info on the Google Static Maps API:
#
#    https://developers.google.com/maps/documentation/staticmaps/
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# our angular service
#-------------------------------------------------------------------------------
AngTangle.service class GMapStaticService

    #---------------------------------------------------------------------------
    constructor: ->

    #---------------------------------------------------------------------------
    # get a static map URL given a set of markers (array of {lat, lon})
    #---------------------------------------------------------------------------
    getMapURL: (stations) ->
        mapURLbits = []
        mapURLbits.push "http://maps.googleapis.com/maps/api/staticmap?sensor=false"
        mapURLbits.push "size=500x400"
        mapURLbits.push "visual_refresh=true"

        for station in stations
            markerBits = []

            # markerBits.push "size:mid"
            markerBits.push "color:red"
            markerBits.push "label:#{station.label}"
            markerBits.push "#{station.lat},#{station.lon}"

            mapURLbits.push "markers=#{markerBits.join '%7C'}"

        return mapURLbits.join("&")

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
