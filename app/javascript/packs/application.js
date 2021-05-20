// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

window.jQuery = window.$ = require("../../../vendor/assets/javascripts/jquery-3.5.1.js")
require("../../../vendor/assets/javascripts/bootstrap.bundle.min.js")
window.d3 = require("../../../vendor/assets/javascripts/d3.min.js")
window.Dygraph = require("../../../vendor/assets/javascripts/dygraph-combined.js")
window.jsonpatch = require("../../../vendor/assets/javascripts/json-patch-duplex.js")
window.m = require("../../../vendor/assets/javascripts/mithril.js")
window._ = require("../../../vendor/assets/javascripts/underscore.js")
window.SeapigClient = require("../../../vendor/assets/javascripts/seapig-client.min.js").SeapigClient
window.SeapigRouter = require("../../../vendor/assets/javascripts/seapig-router.coffee").SeapigRouter
require("../../../vendor/assets/javascripts/sortable.min.js")

require("../execution.coffee")
require("../executions.coffee")
require("../filters.coffee")
require("../layout.coffee")
require("../main.coffee")
require("../spinner.coffee")
require("../statistics.coffee")
require("../utils.coffee")
require("../workers.coffee")

Rails.start()
Turbolinks.start()
ActiveStorage.start()
