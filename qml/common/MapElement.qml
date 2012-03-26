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

import QtQuick 1.1
import QtMobility.location 1.2
import "reittiopas.js" as Reittiopas
import "UIConstants.js" as UIConstants
import "helper.js" as Helper
import "theme.js" as Theme

Item {
    id: map_element
    property bool positioning_active : true
    property alias flickable_map : flickable_map

    function next_station() {
        flickable_map.panToCoordinate(Helper.next_station())
    }
    function previous_station() {
        flickable_map.panToCoordinate(Helper.previous_station())
    }
    function first_station() {
        flickable_map.panToCoordinate(Helper.first_station())
    }

    FlickableMap {
        id: flickable_map
        anchors.fill: parent
    }

    PositionSource {
        id: positionSource
        updateInterval: 500
        active: appWindow.positioning_active
        onPositionChanged: {
            if(appWindow.follow_mode)
                flickable_map.panToCoordinate(current_position.center)
        }
    }

    MapCircle {
        id: current_position
        smooth: true
        color: "red"
        visible: positionSource.position.latitudeValid && positionSource.position.longitudeValid
        radius: 8 * appWindow.scaling_factor
        width: 8 * appWindow.scaling_factor
        center: positionSource.position.coordinate
    }

    MapGroup {
        id: root_group
    }

    Component {
        id: coord_component

        Coordinate {
            id: coord
        }
    }

    Component {
        id: stop

        MapCircle {
            id: stop_circle
            smooth: true
            color: "yellow"
            radius: 6 * appWindow.scaling_factor
            width: 6 * appWindow.scaling_factor
            z: 5
        }
    }

    Component {
        id: group

        MapGroup {
            id: stop_group
            property alias stop_text : stop_text
            property alias stop_circle : stop_circle
            property alias route : route

            MapText {
                id: stop_text
                smooth: true
                font.pixelSize: UIConstants.FONT_LARGE * appWindow.scaling_factor
                offset.x: -(width/2)
                offset.y: 18
                z: 0
            }
            MapCircle {
                id: stop_circle
                smooth: true
                color: "yellow"
                radius: 8 * appWindow.scaling_factor
                width: 8 * appWindow.scaling_factor
                z: -5
            }
            MapPolyline {
                id: route
                smooth: true
                border.width: 6 * appWindow.scaling_factor
                z: -10
            }
        }
    }

    function initialize() {
        flickable_map.map.addMapObject(current_position)

        Helper.clear_objects()

        var route_coords = []
        var current_route = Reittiopas.get_route_instance()
        current_route.dump_route(route_coords)

        for (var index in route_coords) {
            var map_group = group.createObject(appWindow)

            if(!map_group) {
                console.debug("creating object failed")
                return
            }
            var endpointdata = route_coords[index]

            if(!endpointdata) {
                console.debug("no data in result index " + index)
                return
            }

            if(index == 0) {
                if(endpointdata.from.latitude && endpointdata.from.longitude) {
                    var first_station = group.createObject(appWindow)

                    if(!first_station) {
                        console.debug("creating object failed")
                        return
                    }

                    var coord = coord_component.createObject(appWindow)
                    coord.latitude = endpointdata.from.latitude
                    coord.longitude = endpointdata.from.longitude

                    add_station(endpointdata.from.latitude,endpointdata.from.longitude, endpointdata.from.name, first_station)
                    Helper.push_to_objects(first_station)
                }
                else
                    console.debug("invalid coordinates for the first station")


            }
            add_station(endpointdata.to.latitude,endpointdata.to.longitude, endpointdata.to.name, map_group)

            map_group.route.border.color = Theme.theme['general'].TRANSPORT_COLORS[endpointdata.type]

            for(var shapeindex in endpointdata.shape) {

                var shapedata = endpointdata.shape[shapeindex]

                if(!shapedata) {
                    console.debug("no data in shape index " + shapeindex)
                    return
                }

                if(shapedata.y && shapedata.x) {
                    var shape_coord = coord_component.createObject(appWindow)
                    shape_coord.latitude = shapedata.y
                    shape_coord.longitude = shapedata.x

                    if(!shape_coord) {
                        console.debug("creating object failed")
                        return
                    }
                    map_group.route.addCoordinate(shape_coord)

                }
                else
                    console.debug("invalid coordinates for polyline")
            }
            if(endpointdata.type != "walk") {
                for(var stopindex in endpointdata.locs) {
                    var loc = endpointdata.locs[stopindex]

                    if(!loc) {
                        console.debug("no data in locs index " + stopindex)
                        return
                    }

                    if(stopindex != 0 && stopindex != endpointdata.locs.length - 1)
                        add_stop(loc.latitude, loc.longitude)
                }
            }

            Helper.push_to_objects(map_group)
        }
        Helper.set_group_objects(root_group)
        flickable_map.map.addMapObject(root_group)
    }

    function add_station(latitude, longitude, name, map_group) {
        if(latitude && longitude) {
            var coord = coord_component.createObject(appWindow)
            coord.latitude = latitude
            coord.longitude = longitude

            if(!coord) {
                console.debug("creating object failed")
                return
            }

            map_group.stop_text.coordinate = coord;
            map_group.stop_text.text = name?name:""
            map_group.stop_circle.center = coord
            Helper.add_station(coord)
        }
        else
            console.debug("invalid coordinates for a station")
    }

    function add_stop(latitude, longitude) {
        if(latitude && longitude) {

            var stop_object = stop.createObject(appWindow)
            if(!stop_object) {
                console.debug("creating object failed")
                return
            }
            var coord = coord_component.createObject(appWindow)
            coord.latitude = latitude
            coord.longitude = longitude
            stop_object.center = coord;
            Helper.push_to_objects(stop_object)
        }
        else
            console.debug("invalid coordinates for a stop")
    }
}
