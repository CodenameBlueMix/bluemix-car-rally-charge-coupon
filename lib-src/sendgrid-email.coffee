# Licensed under the Apache License. See footer for details.

http = require "http"
Q      = require "q"
cfEnv   = require "cf-env"
utils   = require "./utils"

# optionally override the user defined service name for sendgrid with a user defined env variable
if process.env.SENDGRID_SERVICE_NAME != undefined and process.env.SENDGRID_SERVICE_NAME != ""
  SENDGRID_SERVICE_NAME = process.env.SENDGRID_SERVICE_NAME
else
  # default name of the SendGrid service
  SENDGRID_SERVICE_NAME = "sendgrid"

sgService = cfEnv.getService SENDGRID_SERVICE_NAME

utils.log "using SendGrid service instance #{sgService.name}"

sendgrid  = require('sendgrid')(sgService.credentials.username, sgService.credentials.password);

#-------------------------------------------------------------------------------
# send an email to a customer
#-------------------------------------------------------------------------------
exports.sendEmail = (to, body) ->
  utils.log "sendgrid.sendEmail #{to}"
  deferred = Q.defer()

  email =
    to: to
    from: 'noreply@carrallychargecoupon.com'
    subject: 'Want a Free Car Charge?'
    text: body

  utils.log JSON.stringify(email, undefined , 2)

  sendgrid.send email, (err, json) ->
    if err
      deferred.reject Error "failed to send email to #{to}"
    else
      deferred.resolve json

  deferred.promise

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
