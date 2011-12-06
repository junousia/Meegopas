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

var last_result = []
var last_route_index
var last_route_coordinates = []

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
        return { type:transType[type], code:"metro" }
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

function dump_route(target) {
    var route = last_result[last_route_index][0]
    for (var legindex in route.legs) {
        var legdata = route.legs[legindex]
        var output = {}
        output.from = {}
        output.to = {}

        output.from.latitude = legdata.locs[0].coord.y
        output.from.longitude = legdata.locs[0].coord.x
        output.from.name = legdata.locs[0].name
        output.from.time = legdata.locs[0].time

        output.to.latitude = legdata.locs[legdata.locs.length - 1].coord.y
        output.to.longitude = legdata.locs[legdata.locs.length - 1].coord.x
        output.to.name = legdata.locs[legdata.locs.length - 1].name
        output.to.time = legdata.locs[legdata.locs.length - 1].time

        output.shape = legdata.shape

        output.type = legdata.type
        output.locs = []
        for (var locindex in legdata.locs) {
            var loc = {}
            loc.latitude = legdata.locs[locindex].coord.y
            loc.longitude = legdata.locs[locindex].coord.x
            output.locs.push(loc)
        }

        target.push(output)
    }
}

function dump_stops(index, model) {
    var route = last_result[last_route_index][0]
    var legdata = route.legs[index]

    for (var locindex in legdata.locs) {
        var locdata = legdata.locs[locindex]
        var output = {
            "name" : legdata.locs[locindex].name,
            "coords" : legdata.locs[locindex].coord.x + "," + legdata.locs[locindex].coord.y,
            "arrival_time" : convTime(legdata.locs[locindex].arrTime),
            "departure_time" : convTime(legdata.locs[locindex].depTime),
            "time_diff" : locindex == 0 ? 0 : get_time_difference(convTime(legdata.locs[locindex - 1].depTime), convTime(legdata.locs[locindex].arrTime)).minutes
        }
        model.append(output)
    }
    model.updating = false
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
                "arrival_time" : convTime(legdata.locs[locindex].arrTime),
                "departure_time" : convTime(legdata.locs[locindex].depTime)
            }
        }
        model.append(output)
    }
    model.updating = false
}

function route_handler(routes,model, parameters) {
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
            output.legs[leg] = {"type":translate_typecode(legdata.type,legdata.code).type,
                "code":translate_typecode(legdata.type,legdata.code).code,
                "length":legdata.length,
                "duration":Math.round(legdata.duration/60),
                "from":{},
                "to":{},
                "locs":[]}
            output.legs[leg].from.name = legdata.locs[0].name?legdata.locs[0].name:""
            output.legs[leg].from.time = convTime(legdata.locs[0].depTime)
            output.legs[leg].to.name = legdata.locs[legdata.locs.length - 1].name?legdata.locs[legdata.locs.length - 1].name : ''
            output.legs[leg].to.time = convTime(legdata.locs[legdata.locs.length - 1].arrTime)

            for (var locindex in legdata.locs) {
                output.legs[leg].locs.push(legdata.locs[locindex])
            }

            output.shape = legdata.shape

            // update name and time to first and last leg - not coming automatically from Reittiopas API
            if(leg == 0) {
                output.legs[leg].from.name = parameters.from_name
                output.legs[leg].locs[0].name = parameters.from_name
                output.start = convTime(legdata.locs[0].depTime)
            }
            if(leg == (route.legs.length - 1)) {
                output.legs[leg].to.name = parameters.to_name
                output.legs[leg].locs[output.legs[leg].locs.length - 1].name = parameters.to_name
                output.finish = convTime(legdata.locs[legdata.locs.length - 1].arrTime)
            }

            if(!output.first_transport && legdata.type != "walk")
                output.first_transport = convTime(legdata.locs[0].depTime)
            if(legdata.type != "walk")
                output.last_transport = convTime(legdata.locs[legdata.locs.length - 1].arrTime)

            // amount of walk in the route
            if(legdata.type == "walk")
                output.walk += legdata.length
        }
        last_result.push(output)
        model.append(output)
    }
    model.updating = false
}

function suggestion_handler(suggestions,model) {
    model.clear()
    for (var index in suggestions) {
        var output = {}
        var suggestion = suggestions[index];
        output.name = suggestion.name.split(',', 1).toString()

        if(typeof suggestion.details.houseNumber != 'undefined') {
            output.housenum = suggestion.details.houseNumber
            output.name += " " + suggestion.details.houseNumber
        }

        output.displayname = suggestion.matchedName
        output.city = suggestion.city
        output.type = suggestion.locType
        output.coords = suggestion.coords

        model.append(output)
    }
    model.updating = false
}

function positioning_handler(suggestions,model) {
    model.clear()
    for (var index in suggestions) {                                                                                       
        var output = {}                                                                                                    
        var suggestion = suggestions[index];                                                                               
        output.name = suggestion.name.split(',', 1).toString()                                                             
                                                                                                                           
        output.displayname = suggestion.matchedName                                                                        
        output.city = suggestion.city                                                                                      
        output.type = suggestion.locType                                                                                   
        output.coords = suggestion.coords                                                                                  
                                                                                                                           
        model.append(output)                                                                                           
    }
    model.updating = false
} 

function api_request(parameters, result_handler, model) {
    var req = new XMLHttpRequest()
    model.updating = true
    req.onreadystatechange = function() {
        if (req.readyState == XMLHttpRequest.DONE) {
            if (req.status != 200 && req.status != 304) {
                console.log('HTTP error ' + req.status)
                model.updating = false
                return
            } else {
                var json = eval(req.responseText)
                last_result = json
                result_handler(json, model, parameters)
            }
        }
    }

    parameters.user = USER
    parameters.pass = PASS
    parameters.epsg_in = "wgs84"
    parameters.epsg_out = "wgs84"
    var query = []
    for(var p in parameters) {
        query.push(p + "=" + parameters[p])
    }
    console.log( API + '?' + query.join('&'))
    req.open("GET", API + '?' + query.join('&'))
    req.send()
}

function location_to_address(latitude, longitude, model) {
    var parameters = {}
    parameters.request = 'reverse_geocode'
    parameters.coordinate = longitude + ',' + latitude
    api_request(parameters, positioning_handler, model)
}

function address_to_location(term, model) {
    var parameters = {}
    parameters.request = 'geocode'
    parameters.key = term
    parameters.disable_unique_stop_names = 0
    api_request(parameters, suggestion_handler, model)
}

function route(from, to, from_name, to_name, date, time, timetype, walk_speed, optimize, change_margin, model) {
    var parameters = {}
    parameters.request = 'route'
    parameters.from = from
    parameters.to = to
    parameters.from_name = from_name
    parameters.to_name = to_name
    parameters.time = time
    parameters.date = date
    parameters.timetype = timetype
    parameters.show = 5
    parameters.walk_speed = walk_speed
    parameters.timetype = timetype
    parameters.optimize = optimize
    parameters.lang = "fi"
    parameters.detail= "full"
    parameters.change_margin = change_margin
    api_request(parameters, route_handler, model)
}
