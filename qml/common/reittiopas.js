/*
 * This file is part of the Meegopas, more information at www.gitorious.org/meegopas
 *
 * Author: Jukka Nousiainen <nousiaisenjukka@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * See full license at http://www.gnu.org/licenses/gpl-3.0.html
 */

.pragma library

var API = 'http://api.reittiopas.fi/hsl/prod/'
var USER = 'junousia'
var PASS = 'p3ndolino'
var transType = {}
transType[1] = "bus"
transType[2] = "tram"
transType[3] = "bus"
transType[4] = "bus"
transType[5] = "bus"
transType[6] = "metro"
transType[7] = "boat"
transType[8] = "bus"
transType[12] = "train"
transType[21] = "bus"
transType[22] = "bus"
transType[23] = "bus"
transType[24] = "bus"
transType[25] = "bus"
transType[36] = "bus"
transType[39] = "bus"

//route instance
var _instance = null
var _http_request = null
var _request_parent = null

var _cycling_instance = null

function busCode(code) {
    code = code.slice(1,5).trim().replace(/^[0]+/g,"")
    return code
}

function tramCode(code) {
    code = code.slice(2,5).trim().replace(/^[0]+/g,"")
    return code
}

function trainCode(code) {
    return code[4]
}

function translate_typecode(type, code) {
    if(type == "walk")
        return { type:"walk", code:""}
    else if(transType[type] == "bus")
        return { type:transType[type], code:busCode(code) }
    else if(transType[type] == "train")
        return { type:transType[type], code:trainCode(code) }
    else if(transType[type] == "tram")
        return { type:transType[type], code:tramCode(code) }
    else if(transType[type] == "boat")
        return { type:transType[type], code:"" }
    else if(transType[type] == "metro")
        return { type:transType[type], code:"M" }
    else
        return { type:transType[type], code:code }
}

function convTime(hslTime){
    var time = hslTime;
    return new Date(time.slice(0,4),
                    parseInt(time.slice(4,6), 10),
                    parseInt(time.slice(6,8), 10),
                    time.slice(8,10),
                    time.slice(10,12),
                    00, 00);
}

function get_time_difference(earlierDate,laterDate)
{
       var nTotalDiff = laterDate.getTime() - earlierDate.getTime();
       var oDiff = new Object();

       oDiff.days = Math.floor(nTotalDiff/1000/60/60/24);
       nTotalDiff -= oDiff.days*1000*60*60*24;

       oDiff.hours = Math.floor(nTotalDiff/1000/60/60);
       nTotalDiff -= oDiff.hours*1000*60*60;

       oDiff.minutes = Math.floor(nTotalDiff/1000/60);
       nTotalDiff -= oDiff.minutes*1000*60;

       oDiff.seconds = Math.floor(nTotalDiff/1000);

       return oDiff;
}


/****************************************************************************************************/
/*                     address to location                                                          */
/****************************************************************************************************/
function get_geocode(term) {
    this.parameters = {}
    this.parameters.format = "xml"
    this.parameters.request = "geocode"
    this.parameters.key = term
    this.parameters.disable_unique_stop_names = 0
    this.parameters.user = USER
    this.parameters.pass = PASS
    this.parameters.epsg_in = "wgs84"
    this.parameters.epsg_out = "wgs84"
    var query = []
    for(var p in this.parameters) {
        query.push(p + "=" + this.parameters[p])
    }

    //console.debug( API + '?' + query.join('&'))
    return API + '?' + query.join('&')
}

/****************************************************************************************************/
/*                     location to address                                                          */
/****************************************************************************************************/
function get_reverse_geocode(latitude, longitude) {
    this.parameters = {}
    this.parameters.format = "xml"
    this.parameters.request = 'reverse_geocode'
    this.parameters.coordinate = longitude + ',' + latitude
    this.parameters.user = USER
    this.parameters.pass = PASS
    this.parameters.epsg_in = "wgs84"
    this.parameters.epsg_out = "wgs84"

    var query = []
    for(var p in this.parameters) {
        query.push(p + "=" + this.parameters[p])
    }

    //console.debug( API + '?' + query.join('&'))
    return API + '?' + query.join('&')
}

/****************************************************************************************************/
/*                     Reittiopas query class                                                       */
/****************************************************************************************************/
function reittiopas() {
    this.model = null
}
reittiopas.prototype.api_request = function() {
    _http_request = new XMLHttpRequest()
    this.model.done = false

    _request_parent = this
    _http_request.onreadystatechange = _request_parent.result_handler

    this.parameters.user = USER
    this.parameters.pass = PASS
    this.parameters.epsg_in = "wgs84"
    this.parameters.epsg_out = "wgs84"

    var query = []
    for(var p in this.parameters) {
        if(p == "transport_types") {
            query.push(p + "=" + this.parameters[p].join('|'))
        } else {
            query.push(p + "=" + this.parameters[p])
        }
    }
    console.debug( API + '?' + query.join('&'))
    _http_request.open("GET", API + '?' + query.join('&'))
    _http_request.send()
}

/****************************************************************************************************/
/*                                            Route search                                          */
/****************************************************************************************************/

function new_route_instance(parameters, route_model) {
    if(_instance)
        delete _instance

    _instance = new route_search(parameters, route_model);
    return _instance
}

function get_route_instance() {
    return _instance
}

route_search.prototype = new reittiopas()
route_search.prototype.constructor = route_search
function route_search(parameters, route_model) {
    this.last_result = []
    this.model = route_model

    this.time = parameters.time

    this.last_route_index = -1

    this.from_name = parameters.from_name
    this.to_name = parameters.to_name

    this.parameters = parameters
    delete this.parameters.from_name
    delete this.parameters.to_name
    delete this.parameters.time

    this.parameters.date = Qt.formatDate(this.time, "yyyyMMdd")
    this.parameters.time = Qt.formatTime(this.time, "hhmm")

    this.parameters.format = "json"
    this.parameters.request = "route"
    this.parameters.show = 5
    this.parameters.lang = "fi"
    this.parameters.detail= "full"
    this.api_request()
}

route_search.prototype.parse_json = function(routes, parent) {
    for (var index in routes) {
        var output = {}
        var route = routes[index][0];
        output.length = route.length
        output.duration = Math.round(route.duration/60)
        output.start = 0
        output.finish = 0
        output.first_transport = 0
        output.last_transport = 0
        output.walk = 0
        output.legs = []

        for (var leg in route.legs) {
            var legdata = route.legs[leg]
            output.legs[leg] = {
                "type":translate_typecode(legdata.type,legdata.code).type,
                "code":translate_typecode(legdata.type,legdata.code).code,
                "shortCode":legdata.shortCode,
                "length":legdata.length,
                "duration":Math.round(legdata.duration/60),
                "from":{},
                "to":{},
                "locs":[],
                "leg_number":leg
            }
            output.legs[leg].from.name = legdata.locs[0].name?legdata.locs[0].name:""
            output.legs[leg].from.time = convTime(legdata.locs[0].depTime)
            output.legs[leg].from.shortCode = legdata.locs[0].shortCode
            output.legs[leg].from.latitude = legdata.locs[0].coord.y
            output.legs[leg].from.longitude = legdata.locs[0].coord.x

            output.legs[leg].to.name = legdata.locs[legdata.locs.length - 1].name?legdata.locs[legdata.locs.length - 1].name : ''
            output.legs[leg].to.time = convTime(legdata.locs[legdata.locs.length - 1].arrTime)
            output.legs[leg].to.shortCode = legdata.locs[legdata.locs.length - 1].shortCode
            output.legs[leg].to.latitude = legdata.locs[legdata.locs.length - 1].coord.y
            output.legs[leg].to.longitude = legdata.locs[legdata.locs.length - 1].coord.x

            for (var locindex in legdata.locs) {
                var locdata = legdata.locs[locindex]

                output.legs[leg].locs[locindex] = {
                    "name" : locdata.name,
                    "shortCode" : locdata.shortCode,
                    "latitude" : locdata.coord.y,
                    "longitude" : locdata.coord.x,
                    "arrTime" : convTime(locdata.arrTime),
                    "depTime" : convTime(locdata.depTime),
                    "time_diff" : locindex === 0 ? 0 : get_time_difference(convTime(locdata.depTime), convTime(locdata.arrTime)).minutes
                }
            }
            output.legs[leg].shape = legdata.shape

            // update name and time to first and last leg - not coming automatically from Reittiopas API
            if(leg == 0) {
                output.legs[leg].from.name = parent.from_name
                output.legs[leg].locs[0].name = parent.from_name
                output.start = convTime(legdata.locs[0].depTime)
            }
            if(leg == (route.legs.length - 1)) {
                output.legs[leg].to.name = _request_parent.to_name
                output.legs[leg].locs[output.legs[leg].locs.length - 1].name = parent.to_name
                output.finish = convTime(legdata.locs[legdata.locs.length - 1].arrTime)
            }

            /* update the first and last time using any other transportation than walking */
            if(!output.first_transport && legdata.type != "walk")
                output.first_transport = convTime(legdata.locs[0].depTime)
            if(legdata.type != "walk")
                output.last_transport = convTime(legdata.locs[legdata.locs.length - 1].arrTime)

            // amount of walk in the route
            if(legdata.type == "walk")
                output.walk += legdata.length
        }
        parent.last_result.push(output)
        parent.model.append(output)
    }
}

route_search.prototype.result_handler = function() {
    if (_http_request.readyState == XMLHttpRequest.DONE) {
        if (_http_request.status != 200 && _http_request.status != 304) {
            //console.debug('HTTP error ' + _http_request.status)
            this.model.done = true
            return
        }
    } else {
        return
    }

    var parent = _request_parent
    var routes = eval(_http_request.responseText)

    _request_parent.parse_json(routes, parent)
    _request_parent.model.done = true
}

route_search.prototype.dump_route = function(target) {
    var route = this.last_result[this.last_route_index]
    for (var legindex in route.legs) {
        target.push(route.legs[legindex])
    }
}

route_search.prototype.dump_stops = function(index, model) {
    var route = this.last_result[this.last_route_index]
    var legdata = route.legs[index]
    for (var locindex in legdata.locs) {
        var locdata = legdata.locs[locindex]
        /* for walking add only first and last "stop" */
        if(legdata.type == "walk" && locindex != 0 && locindex != legdata.locs.length - 1) { }
        else {
            model.append(legdata.locs[locindex])
        }
    }
    model.done = true
}

route_search.prototype.dump_legs = function(index, model) {
    var route = this.last_result[index]

    // save used route index for dumping stops
    this.last_route_index = index

    for (var legindex in route.legs) {
        var legdata = route.legs[legindex]
        var station = {}
        station.type = "station"
        station.name = legdata.locs[0].name?legdata.locs[0].name:''
        station.time = legdata.locs[0].depTime
        station.code = ""
        station.shortCode = legdata.locs[0].shortCode
        station.length = ""
        station.duration = ""
        station.leg_number = ""
        station.locs = []
        model.append(station)

        model.append(legdata)
    }
    var last_station = {"type" : "station",
                        "name" : legdata.locs[legdata.locs.length - 1].name ? legdata.locs[legdata.locs.length - 1].name : "",
                        "time" : legdata.locs[legdata.locs.length - 1].arrTime,
                        "leg_number" : ""}

    model.append(last_station)

    model.done = true
}

location_to_address.prototype = new reittiopas
location_to_address.prototype.constructor = location_to_address
function location_to_address(latitude, longitude, model) {
    this.model = model
    this.parameters = {}
    this.parameters.request = "reverse_geocode"
    this.parameters.coordinate = longitude.replace(',','.') + ',' + latitude.replace(',','.')
    this.api_request(this.positioning_handler)
}

location_to_address.prototype.positioning_handler = function() {
    if (_http_request.readyState == XMLHttpRequest.DONE) {
        if (_http_request.status != 200 && _http_request.status != 304) {
            //console.debug('HTTP error ' + _http_request.status)
            this.model.done = true
            return
        }
    } else {
        return
    }

    var suggestions = eval(_http_request.responseText)

    _request_parent.model.clear()
    for (var index in suggestions) {
        var output = {}
        var suggestion = suggestions[index];
        output.name = suggestion.name.split(',', 1).toString()

        output.displayname = suggestion.matchedName
        output.city = suggestion.city
        output.type = suggestion.locType
        output.coord = suggestion.coord

        _request_parent.model.append(output)
    }
    _request_parent.model.done = true
}
/****************************************************************************************************/
/*                                            Cycling search                                        */
/****************************************************************************************************/

function new_cycling_instance(parameters, route_model) {
    if(_cycling_instance)
        delete _cycling_instance

    _cycling_instance = new cycling_search(parameters, route_model)
    return _cycling_instance
}

function get_cycling_instance() {
    return _cycling_instance
}

cycling_search.prototype = new reittiopas()
cycling_search.prototype.constructor = cycling_search
function cycling_search(parameters, route_model) {
    this.last_result = {}
    this.model = route_model

    this.from_name = parameters.from_name
    this.to_name = parameters.to_name

    this.parameters = parameters
    delete this.parameters.from_name
    delete this.parameters.to_name

    this.parameters.format = "json"
    this.parameters.request = "cycling"
    this.parameters.lang = "fi"
    this.parameters.detail= "full"
    this.api_request()
}

cycling_search.prototype.result_handler = function() {
    if (_http_request.readyState == XMLHttpRequest.DONE) {
        if (_http_request.status != 200 && _http_request.status != 304) {
            //console.debug('HTTP error ' + _http_request.status)
            this.model.done = true
            return
        }
    } else {
        return
    }
    var parent = _request_parent
    var routes = eval('(' + _http_request.responseText + ')')
    _request_parent.last_result = routes
    _request_parent.model.done = true
}
