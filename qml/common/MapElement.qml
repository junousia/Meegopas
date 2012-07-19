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
    property bool positioningActive : true
    property alias flickable_map : flickable_map

    signal newCycling(int length)

    function next_station() {
        flickable_map.panToCoordinate(Helper.next_station())
    }
    function previous_station() {
        flickable_map.panToCoordinate(Helper.previous_station())
    }
    function first_station() {
        flickable_map.panToCoordinate(Helper.first_station())
    }

    function removeAll() {
        flickable_map.map.removeMapObject(root_group)
    }

    FlickableMap {
        id: flickable_map
        anchors.fill: parent
    }

    PositionSource {
        id: positionSource
        updateInterval: 200
        active: appWindow.positioningActive
        onPositionChanged: {
            if(appWindow.followMode) {
                flickable_map.panToCoordinate(current_position.coordinate)
            }
        }
    }

    Connections {
        target: appWindow
        onFollowModeEnabled: {
            flickable_map.panToCoordinate(positionSource.position.coordinate)
        }
    }

    Binding {
        target: current_position
        property: "coordinate"
        value: positionSource.position.coordinate
    }

    MapImage {
        id: current_position
        smooth: true
        source: "qrc:/images/position.png"
        visible: positionSource.position.latitudeValid && positionSource.position.longitudeValid && appWindow.positioningActive
        width: 30 * appWindow.scalingFactor
        height: 30 * appWindow.scalingFactor
        offset.y: -30  * appWindow.scalingFactor / 2
        offset.x: -30  * appWindow.scalingFactor / 2
        z: 49
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

        MapImage {
            id: stop_circle
            smooth: true
            source: "qrc:/images/station.png"
            height: 20 * appWindow.scalingFactor
            width: 20 * appWindow.scalingFactor
            offset.y: -20 * appWindow.scalingFactor / 2
            offset.x: -20 * appWindow.scalingFactor / 2
            z: 45
        }
    }

    Component {
        id: endpoint
        MapImage {
            smooth: true
            height: 50 * appWindow.scalingFactor
            width: 50 * appWindow.scalingFactor
            offset.y: -50 * appWindow.scalingFactor + 5
            offset.x: -50 * appWindow.scalingFactor / 2
            z: 50
        }
    }

    Component {
        id: group

        MapGroup {
            id: stop_group
            property alias station_text : station_text
            property alias station : station
            property alias route : route

            MapText {
                id: station_text
                smooth: true
                font.pixelSize: UIConstants.FONT_LARGE * appWindow.scalingFactor
                offset.x: -(width/2)
                offset.y: 18
                z: 48
            }
            MapImage {
                id: station
                smooth: true
                source: "qrc:/images/stop.png"
                height: 30 * appWindow.scalingFactor
                width: 30 * appWindow.scalingFactor
                offset.y: -30 * appWindow.scalingFactor / 2
                offset.x: -30 * appWindow.scalingFactor / 2
                z: 45
            }
            MapPolyline {
                id: route
                smooth: true
                border.width: 8 * appWindow.scalingFactor
                z: 30
            }
        }
    }

    function initialize() {
        flickable_map.map.addMapObject(current_position)

        Helper.clear_objects()
        var coord
        var endpoint_object
        var route_coord = []
        var current_route = Reittiopas.get_route_instance()
        current_route.dump_route(route_coord)

        for (var index in route_coord) {
            var map_group = group.createObject(appWindow)
            var endpointdata = route_coord[index]

            if(index == 0) {
                var first_station = group.createObject(appWindow)

                coord = coord_component.createObject(appWindow)
                coord.latitude = endpointdata.from.latitude
                coord.longitude = endpointdata.from.longitude

                add_station(coord, endpointdata.from.name, first_station)
                Helper.push_to_objects(first_station)

                endpoint_object = endpoint.createObject(appWindow)
                endpoint_object.coordinate = coord
                endpoint_object.source = "qrc:/images/start.png"
                Helper.push_to_objects(endpoint_object)
            }
            coord = coord_component.createObject(appWindow)
            coord.latitude = endpointdata.to.latitude
            coord.longitude = endpointdata.to.longitude

            add_station(coord, endpointdata.to.name, map_group)

            if(index == route_coord.length - 1) {
                endpoint_object = endpoint.createObject(appWindow)
                endpoint_object.coordinate = coord
                endpoint_object.source = "qrc:/images/finish.png"
                Helper.push_to_objects(endpoint_object)
            }

            map_group.route.border.color = Theme.theme['general'].TRANSPORT_COLORS[endpointdata.type]

            for(var shapeindex in endpointdata.shape) {
                var shapedata = endpointdata.shape[shapeindex]

                var shape_coord = coord_component.createObject(appWindow)
                shape_coord.latitude = shapedata.y
                shape_coord.longitude = shapedata.x

                map_group.route.addCoordinate(shape_coord)
            }
            if(endpointdata.type != "walk") {
                for(var stopindex in endpointdata.locs) {
                    var loc = endpointdata.locs[stopindex]

                    if(stopindex != 0 && stopindex != endpointdata.locs.length - 1)
                        add_stop(loc.latitude, loc.longitude)
                }
            }

            Helper.push_to_objects(map_group)
        }
        Helper.set_group_objects(root_group)
        flickable_map.map.addMapObject(root_group)
    }

    function initialize_cycling() {
        flickable_map.map.addMapObject(current_position)

        Helper.clear_objects()

        var route_coord = []
        var current_route = Reittiopas.get_cycling_instance()

        var last_result = current_route.last_result

        map_element.newCycling(last_result.length)

        for(var index in last_result.path) {
            var leg = last_result.path[index]
            var map_group = group.createObject(appWindow)
            map_group.route.border.color = Theme.theme['general'].TRANSPORT_COLORS[leg.type]

            for(var pointindex in leg.points) {
                var point = leg.points[pointindex]
                if(point.y && point.x) {
                    var shape_coord = coord_component.createObject(appWindow)
                    shape_coord.latitude = point.y
                    shape_coord.longitude = point.x
                    map_group.route.addCoordinate(shape_coord)
                    Helper.add_station(shape_coord)

                    var endpoint_object
                    var stop_object
                    if(index == 0 && pointindex == 0) {
                        endpoint_object = endpoint.createObject(appWindow)
                        endpoint_object.coordinate = shape_coord
                        endpoint_object.source = "qrc:/images/start.png"
                        Helper.push_to_objects(endpoint_object)

                        stop_object = stop.createObject(appWindow)
                        stop_object.coordinate = shape_coord
                        Helper.push_to_objects(stop_object)
                    } else if(index == last_result.path.length - 1 && pointindex == leg.points.length - 1) {
                        endpoint_object = endpoint.createObject(appWindow)
                        endpoint_object.coordinate = shape_coord
                        endpoint_object.source = "qrc:/images/finish.png"
                        Helper.push_to_objects(endpoint_object)

                        stop_object = stop.createObject(appWindow)
                        stop_object.coordinate = shape_coord
                        Helper.push_to_objects(stop_object)
                    }
                }
            }

            Helper.push_to_objects(map_group)
        }

        Helper.set_group_objects(root_group)
        flickable_map.map.addMapObject(root_group)
        first_station()
    }

    function add_station(coord, name, map_group) {
        map_group.station_text.coordinate = coord
        map_group.station_text.text = name?name:""
        map_group.station.coordinate = coord

        Helper.add_station(coord)
    }

    function add_stop(latitude, longitude) {
        var stop_object = stop.createObject(appWindow)
        if(!stop_object) {
            console.debug("creating object failed")
            return
        }
        var coord = coord_component.createObject(appWindow)
        coord.latitude = latitude
        coord.longitude = longitude
        stop_object.coordinate = coord
        Helper.push_to_objects(stop_object)
    }
}
