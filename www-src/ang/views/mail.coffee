# Licensed under the Apache License. See footer for details.

AngTangle.controller ($scope, $location, Customers) ->
    $scope.setSubtitle "mail"
    $scope.pageHost = $location.host()
    $scope.customers = Customers.getCustomers()

    cindex = 0

    $scope.$watch "customers.length", (vnew, vold) ->
        if vnew > 0
            $scope.customer = $scope.customers[cindex]

    $scope.getCustomerId = ->
        $scope.customer.cid

    $scope.custPrev = ->
        if cindex <= 0
            cindex = $scope.customers.length-1
        else
            cindex--

        $scope.customer = $scope.customers[cindex]

    $scope.custNext = ->
        if cindex >= $scope.customers.length-1
            cindex = 0
        else
            cindex++

        $scope.customer = $scope.customers[cindex]

    return

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
