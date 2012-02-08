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

Item {
    property bool positioning_active : true
    property bool follow_position : false
    property alias flickable_map : flickable_map
    function next_station() {
        flickable_map.panToCoordinate(Helper.next_station())
    }
    function previous_station() {
        flickable_map.panToCoordinate(Helper.previous_station())
    }
    FlickableMap {
        id: flickable_map
        anchors.fill: parent
    }

    PositionSource {
        id: positionSource
        updateInterval: 500
        active: positioning_active
        onPositionChanged: {
            if(follow_position)
                flickable_map.panToCoordinate(current_position.center)
        }
    }

    MapCircle {
        id: current_position
        smooth: true
        color: "green"
        visible: positionSource.position.latitudeValid && positionSource.position.longitudeValid
        radius: 8 * appWindow.scaling_factor
        width: 8 * appWindow.scaling_factor
        center: positionSource.position.coordinate
    }

    Component {
        id: group
        MapGroup {
            property alias stop_text : stop_text
            property alias stop_circle : stop_circle
            property alias route : route

            MapText {
                id: stop_text
                smooth: true
                font.pixelSize: UIConstants.FONT_LARGE * appWindow.scaling_factor
                font.bold: true
                offset.x: -(width/2)
                offset.y: 10
                z: -10
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
        var route_coords = []
        var current_route = Reittiopas.get_route_instance()
        current_route.dump_route(route_coords)

        var current_z = 0;

        for (var index in route_coords) {
            var map_group = group.createObject(flickable_map)
            var endpointdata = route_coords[index]

            if(index == 0) {
                var first_station = group.createObject(flickable_map)
                var coord = Qt.createQmlObject('import QtMobility.location 1.2; Coordinate{latitude:' + endpointdata.from.latitude + ';longitude:' + endpointdata.from.longitude + ';}', group, "coord")
                flickable_map.panToCoordinate(coord)
                add_station(endpointdata.from.latitude,endpointdata.from.longitude, endpointdata.from.name, first_station)
                flickable_map.map.addMapObject(first_station);
            }

            add_station(endpointdata.to.latitude,endpointdata.to.longitude, endpointdata.to.name, map_group)

            map_group.route.border.color = endpointdata.type == "walk" ? "green" : "blue"
            map_group.z = current_z++;

            for(var shapeindex in endpointdata.shape) {
                var shapedata = endpointdata.shape[shapeindex]
                map_group.route.addCoordinate(Qt.createQmlObject('import QtMobility.location 1.2; Coordinate{latitude:' + shapedata.y + ';longitude:' + shapedata.x + ';}', flickable_map, "coord"));
            }

            flickable_map.map.addMapObject(map_group);
        }
    }

    function add_station(latitude, longitude, name, map_group) {
        var coord = Qt.createQmlObject('import QtMobility.location 1.2; Coordinate{latitude:' + latitude + ';longitude:' + longitude + ';}', group, "coord")
        map_group.stop_text.coordinate = coord;
        map_group.stop_text.text = name?name:""
        map_group.stop_circle.center = coord
        Helper.add_station(coord)
    }

    Component.onCompleted: {
        initialize()
    }
}
