# Licensed under the Apache License. See footer for details.

AngTangle.controller ($scope, GMapStatic, $routeParams, Locations) ->
    $scope.setSubtitle "map"

    $scope.gmapStatic = GMapStatic
    $scope.locations  = Locations
    $scope.lat        = $routeParams.lat
    $scope.lon        = $routeParams.lon

    setMapElement $scope

    return

#-------------------------------------------------------------------------------
setMapElement = ($scope) ->
    lat = $scope.lat
    lon = $scope.lon

    $scope.stations = $scope.locations.getStationsForLocation {lat, lon}

    $scope.$watch "stations.length", (vnew, vold) ->
        if vnew > 0
           $scope.mapURL = $scope.gmapStatic.getMapURL $scope.stations

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
