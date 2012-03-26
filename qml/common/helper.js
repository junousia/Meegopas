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

var stations = []
var current_station = 0

var objects = []

function push_to_objects(item) {
    if(item)
        objects.push(item)
}

function set_group_objects(group) {
    group.objects = objects
}

function clear_objects() {
    objects = []
    stations = []
    current_station = 0
}

function add_station(station) {
    if(station)
        stations.push(station)
}

function next_station() {
    return stations[++current_station%stations.length]
}

function previous_station() {
    return stations[--current_station%stations.length]
}

function first_station() {
    current_station = 0
    return stations[current_station]
}

function switch_locations(from, to) {
    var templo = from.destination_name
    var tempcoord = from.destination_coords
    var tempindex = from.selected_favorite

    from.clear()
    from.updateLocation(to.destination_name, 0, to.destination_coords)
    from.selected_favorite = to.selected_favorite

    to.clear()
    to.updateLocation(templo, 0, tempcoord)
    to.selected_favorite = tempindex
}

function parse_disruption_time(time) {
        var newtime = time;
        return new Date(newtime.slice(0,4),
                        parseInt(newtime.slice(5,7),10) - 1,
                        newtime.slice(8,10),
                        newtime.slice(11,13),
                        newtime.slice(14,16),
                        00, 00);
}
