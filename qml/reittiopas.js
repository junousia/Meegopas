.pragma library

var API = 'http://api.reittiopas.fi/hsl/beta/'
var USER = 'junousia'
var PASS = 'p3ndolino'

var transType = {}
transType[1] = "bus"
transType[2] = "tram"
transType[3] = "bus"
transType[4] = "bus"
transType[5] = "bus"
transType[6] = "metro"
transType[7] = "ferry"
transType[8] = "bus"
transType[9] = "bus"
transType[10] = "bus"
transType[11] = "bus"
transType[12] = "train"
transType[13] = "train"
transType[14] = "other"
transType[21] = "bus"
transType[22] = "bus"
transType[23] = "bus"
transType[24] = "bus"
transType[25] = "bus"

var last_result = []
var last_route_index

function busCode(code) {
    code = code.slice(1,5)
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
    else
        return { type:transType[type], code:code }
}

function convTime(hslTime){
    var time = hslTime;
    //console.log(time.slice(0,4) + " " + parseInt(time.slice(4,6), 10) + " " + parseInt(time.slice(6,8), 10) + " " + time.slice(8,10) + " " + time.slice(10,12))
    return new Date(time.slice(0,4),
                    parseInt(time.slice(4,6), 10),
                    parseInt(time.slice(6,8), 10) - 1,
                    time.slice(8,10),
                    time.slice(10,12),
                    00, 00);
}

function dump_stops(index, model) {
    var route = last_result[last_route_index][0]

    // save used route index for dumping stops
    last_route_index = index

    var legdata = route.legs[index]

    for (var locindex in legdata.locs) {
        var locdata = legdata.locs[locindex]
        var output = {
            "name" : legdata.locs[locindex].name,
            "coords" : legdata.locs[locindex].coord.x + "," + legdata.locs[locindex].coord.y,
            "arrTime" : convTime(legdata.locs[locindex].arrTime),
            "depTime" : convTime(legdata.locs[locindex].depTime)
        }
        model.append(output)
    }
}

function dump_legs(index, model) {
    var route = last_result[index][0]

    // save used route index for dumping stops
    last_route_index = index

    for (var legindex in route.legs) {
        var legdata = route.legs[legindex]
        var output = {"type":translate_typecode(legdata.type,legdata.code).type,
            "code":translate_typecode(legdata.type,legdata.code).code,
            "length":legdata.length,
            "duration":Math.round(legdata.duration/60),
            "from":{},
            "to":{},
            "locs":[]}
        output.from.name = legdata.locs[0].name?legdata.locs[0].name:''
        output.from.time = convTime(legdata.locs[0].depTime)
        output.to.name = legdata.locs[legdata.locs.length - 1].name?legdata.locs[legdata.locs.length - 1].name : ''
        output.to.time = convTime(legdata.locs[legdata.locs.length - 1].arrTime)
        for (var locindex in legdata.locs) {
            var locdata = legdata.locs[locindex]
            output.locs[locindex] = {
                "name" : legdata.locs[locindex].name,
                "coords" : legdata.locs[locindex].coord.x + "," + legdata.locs[locindex].coord.y,
                "arrTime" : convTime(legdata.locs[locindex].arrTime),
                "depTime" : convTime(legdata.locs[locindex].depTime)
            }
        }
        model.append(output)
    }
}

function route_handler(routes,model) {
    for (var index in routes) {
        var output = {}
        var route = routes[index][0];
        output.length = route.length
        output.duration = Math.round(route.duration/60)
        output.start = 0
        output.finish = 0
        output.walk = 0
        output.legs = []
        for (var leg in route.legs) {
            var legdata = route.legs[leg]
            output.legs[leg] = {"type":translate_typecode(legdata.type,legdata.code).type,
                "code":translate_typecode(legdata.type,legdata.code).code,
                "length":legdata.length,
                "duration":Math.round(legdata.duration/60),
                "from":{},
                "to":{}}
            output.legs[leg].from.name = legdata.locs[0].name?legdata.locs[0].name:''
            output.legs[leg].from.time = convTime(legdata.locs[0].depTime)
            output.legs[leg].to.name = legdata.locs[legdata.locs.length - 1].name?legdata.locs[legdata.locs.length - 1].name : ''
            output.legs[leg].to.time = convTime(legdata.locs[legdata.locs.length - 1].arrTime)

            if(leg == 1) {
                output.start = convTime(legdata.locs[0].depTime)
            } else if(leg == route.legs.length - 1) {
                output.finish = convTime(legdata.locs[legdata.locs.length - 1].arrTime)
            }

            // amount of walk in the route
            if(legdata.type == "walk")
                output.walk += legdata.length
        }
        last_result.push(output)
        model.append(output)
    }
}

function suggestion_handler(suggestions,model) {
    for (var index in suggestions) {
        var output = {}
        var suggestion = suggestions[index];
        output.name = suggestion.matchedName
        output.displayname = suggestion.matchedName
        output.city = suggestion.city
        output.type = suggestion.locType
        output.coords = suggestion.coords
        model.append(output)
    }
}

function api_request(parameters, result_handler, model, result_callback) {
    var req = new XMLHttpRequest();
    req.onreadystatechange = function() {
        if (req.readyState == XMLHttpRequest.DONE) {
            if (req.status != 200 && req.status != 304) {
                console.log('HTTP error ' + req.status);
                return;
            } else {
                var json = eval(req.responseText);
                last_result = json
                result_handler(json, model);
            }
        }
    }

    parameters.user = USER;
    parameters.pass = PASS;

    var query = [];
    for(var p in parameters) {
        query.push(p + "=" + parameters[p]);
    }
    console.log( API + '?' + query.join('&'));
    req.open("GET", API + '?' + query.join('&'));
    req.send();
}


function location_to_address(latitude, longitude, result_handler) {
    var parameters = {};
    parameters.request = 'reverse_geocode';
    parameters.coordinate = longitude + ',' + latitude;
    api_request(parameters, function(json) {
                    result_handler(json);
                } );
}

function address_to_location(term, model) {
    var parameters = {};
    parameters.request = 'geocode';
    parameters.key = term;
    parameters.disable_unique_stop_names = 0
    api_request(parameters, suggestion_handler, model);
}

function route(from, to, date, time, timetype, walk_speed, model) {
    var parameters = {};
    parameters.request = 'route';
    parameters.from = from;
    parameters.to = to;
    parameters.time = time
    parameters.date = date
    parameters.timetype = timetype;
    parameters.show = 5;
    parameters.walk_speed = walk_speed
    parameters.timetype = timetype
    parameters.lang = "fi"
    //parameters.detail = "limited"
    api_request(parameters, route_handler, model);
}
