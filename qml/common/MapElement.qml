// adapted from example: http://developer.qt.nokia.com/wiki/QML_Maps_with_Pinch_Zoom

import QtQuick 1.1
import QtMobility.location 1.2
import "reittiopas.js" as Reittiopas
import "UIConstants.js" as UIConstants

Item {
    Component {
        id: route
        MapPolyline {}
    }

    Component {
        id: stop
        MapImage {}
    }

    Component {
        id: stop_circle
        MapCircle {}
    }

    Component {
        id: stop_text
        MapText {}
    }

    function add_station(latitude, longitude, name) {
        var textObj = stop_text.createObject(null)
        textObj.coordinate = Qt.createQmlObject('import QtMobility.location 1.2; Coordinate{latitude:' + latitude + ';longitude:' + longitude + ';}', stop, "coord");
        textObj.text = name?name:""
        textObj.font.pixelSize = UIConstants.FONT_DEFAULT * appWindow.scaling_factor
        textObj.visible = true
        textObj.offset.x = -(textObj.width/2)
        textObj.offset.y = 10
        textObj.z = 150
        map.addMapObject(textObj)

        var stopObj = stop.createObject(null)
        stopObj.coordinate = Qt.createQmlObject('import QtMobility.location 1.2; Coordinate{latitude:' + latitude + ';longitude:' + longitude + ';}', stop, "coord");
        stopObj.visible = true
        stopObj.offset.x = -15
        stopObj.offset.y = -40
        stopObj.z = 100
        stopObj.source = "qrc:/images/mapmarker.png"
        map.addMapObject(stopObj)

        var circleObj = stop_circle.createObject(null)
        circleObj.center = Qt.createQmlObject('import QtMobility.location 1.2; Coordinate{latitude:' + latitude + ';longitude:' + longitude + ';}', stop, "coord");
        circleObj.visible = true
        circleObj.border.color = "red"
        circleObj.radius = 5
        circleObj.border.width = 5
        circleObj.z = 50
        map.addMapObject(circleObj)
    }

    function initialize() {
        var leg_endpoints = []
        var route_coords = []
        var current_route = Reittiopas.get_route_instance()
        current_route.dump_route(route_coords)
        console.log(" ")
        // draw stop/stations
        for (var index in route_coords) {
            var endpointdata = route_coords[index]

            if(index == 0) {
                add_station(endpointdata.from.latitude,endpointdata.from.longitude, endpointdata.from.name)
                map.center = Qt.createQmlObject('import QtMobility.location 1.2; Coordinate{latitude:' + endpointdata.from.latitude + ';longitude:' + endpointdata.from.longitude + ';}', stop, "coord");
            }

            add_station(endpointdata.to.latitude,endpointdata.to.longitude, endpointdata.to.name)

            var lineObj = route.createObject(null);

            lineObj.border.width = 3
            lineObj.border.color = endpointdata.type == "walk" ? "green" : "blue"
            lineObj.smooth = true
            for(var shapeindex in endpointdata.shape) {
                var shapedata = endpointdata.shape[shapeindex]
                lineObj.addCoordinate(Qt.createQmlObject('import QtMobility.location 1.2; Coordinate{latitude:' + shapedata.y + ';longitude:' + shapedata.x + ';}', stop, "coord"));
            }
            for (var routeindex in endpointdata.locs) {
                var coorddata = endpointdata.locs[routeindex]

                if(endpointdata.type != "walk" && routeindex != 0) {
                    var stopObj = stop_circle.createObject(null)
                    stopObj.center = Qt.createQmlObject('import QtMobility.location 1.2; Coordinate{latitude:' + coorddata.latitude + ';longitude:' + coorddata.longitude + ';}', stop, "coord");
                    stopObj.visible = true
                    stopObj.border.color = "red"
                    stopObj.radius = 5
                    stopObj.border.width = 5
                    stopObj.z = 25
                    map.addMapObject(stopObj)
                }
            }
            map.addMapObject(lineObj);
        }
    }

    Component.onCompleted: {
        initialize()
    }

    Map {
        id: map
        anchors.fill: parent
        plugin: Plugin { name: "nokia" }
        mapType: Map.StreetMap
        zoomLevel: 15
        center: Coordinate {
            latitude: 60.2183967313
            longitude: 24.8043979003
        }
    }

    PinchArea {
        id: pincharea

        property double __oldZoom

        anchors.fill: parent

        function calcZoomDelta(zoom, percent) {
            return zoom + Math.log(percent)/Math.log(2)
        }

        onPinchStarted: {
            __oldZoom = map.zoomLevel
        }

        onPinchUpdated: {
            map.zoomLevel = calcZoomDelta(__oldZoom, pinch.scale)
        }

        onPinchFinished: {
            map.zoomLevel = calcZoomDelta(__oldZoom, pinch.scale)
        }
    }

    MouseArea {
        id: mousearea

        property bool __isPanning: false
        property int __lastX: -1
        property int __lastY: -1

        anchors.fill : parent

        onPressed: {
            __isPanning = true
            __lastX = mouse.x
            __lastY = mouse.y
        }

        onReleased: {
            __isPanning = false
        }

        onPositionChanged: {
            if (__isPanning) {
                var dx = mouse.x - __lastX
                var dy = mouse.y - __lastY
                map.pan(-dx, -dy)
                __lastX = mouse.x
                __lastY = mouse.y
            }
        }

        onCanceled: {
            __isPanning = false;
        }
    }
}
