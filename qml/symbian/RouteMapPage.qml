// adapted from example: http://developer.qt.nokia.com/wiki/QML_Maps_with_Pinch_Zoom

import QtQuick 1.1
import QtWebKit 1.0
import com.nokia.symbian 1.0
import QtMobility.location 1.2
import "../common/reittiopas.js" as Reittiopas

Page {
    id: page
    tools: mapTools
    anchors.fill: parent

    ToolBarLayout {
        id: mapTools
        x: 0
        y: 0
        ToolButton { iconSource: "toolbar-back"; onClicked: { pageStack.pop(); } }
    }

    Component {
        id: route
        MapPolyline {}
    }

    Component {
        id: stop
        MapCircle {}
    }

    function initialize() {
        var leg_endpoints = []
        var route_coords = []
        Reittiopas.dump_leg_endpoints(leg_endpoints)
        Reittiopas.dump_route_coords(route_coords)

        // draw stop/stations
        for (var index in leg_endpoints) {
            var endpointdata = leg_endpoints[index]
            var circleObj = stop.createObject(null);
            circleObj.center = Qt.createQmlObject('import QtMobility.location 1.1; Coordinate{latitude:' + endpointdata.latitude + ';longitude:' + endpointdata.longitude + ';}', stop, "coord");
            circleObj.visible = true
            circleObj.border.color = "red"
            circleObj.radius = 15
            circleObj.border.width = 5
            map.addMapObject(circleObj)
            if(index == 0) {
                map.center = Qt.createQmlObject('import QtMobility.location 1.1; Coordinate{latitude:' + endpointdata.latitude + ';longitude:' + endpointdata.longitude + ';}', stop, "coord");
            }
            circleObj.center = Qt.createQmlObject('import QtMobility.location 1.1; Coordinate{latitude:' + endpointdata.latitude + ';longitude:' + endpointdata.longitude + ';}', stop, "coord");
        }

        // draw route
        var lineObj = route.createObject(null);

        lineObj.border.width = 3
        lineObj.border.color = "blue"

        for (var routeindex in route_coords) {
            var coorddata = route_coords[routeindex]
            lineObj.addCoordinate(Qt.createQmlObject('import QtMobility.location 1.1; Coordinate{latitude:' + coorddata.latitude + ';longitude:' + coorddata.longitude + ';}', stop, "coord"));
        }
        map.addMapObject(lineObj);
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
