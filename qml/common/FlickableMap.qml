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

/* Modified from the example by Clovis Scotti <scotti@ieee.org>, http://cpscotti.com/blog/?p=52, released with GPL 3.0 */

import QtQuick 1.1
import QtMobility.location 1.2
import Qt.labs.gestures 1.0

Flickable {
    id: mapFlickable
    property alias map: map
    property double defaultLatitude: 60.1687069096
    property double defaultLongitude: 24.9407379411
    property int  defaultZoomLevel: 16

    property double centeredContentX: map.size.width*0.75
    property double centeredContentY: map.size.height*0.75

    interactive: !appWindow.follow_mode

    contentWidth: map.size.width * 2
    contentHeight: map.size.height * 2
    flickableDirection: Flickable.HorizontalAndVerticalFlick
    boundsBehavior: Flickable.DragAndOvershootBounds
    flickDeceleration: 4000
    maximumFlickVelocity: 1000

    pressDelay: 500
    clip: true
    function updateSizes()
    {
        map.transformOrigin = Item.Center
        map.scenter.x = map.width/2.0
        map.scenter.y = map.height/2.0
        updateViewPort()
    }
    Component.onCompleted: {
        updateSizes()
        contentX = centeredContentX
        contentY = centeredContentY
        map.pos.x = map.size.width/2
        map.pos.y = map.size.height/2
    }
    function updateViewPort() {
        map.pan((contentX-centeredContentX)/map.getSkale,(contentY-centeredContentY)/map.getSkale)

        contentX = centeredContentX
        contentY = centeredContentY
    }
    onMovementEnded: {
        updateViewPort()
    }
    Map {
        smooth: true
        id: map

        size.width: mapFlickable.width * 2
        size.height: mapFlickable.height * 2
        zoomLevel: defaultZoomLevel
        plugin: Plugin {
            name: "nokia"
            parameters: [
                PluginParameter {
                    name: "mapping.token"
                    value: "QYpeZ4z7gwhQr7iW0hOTUQ%3D%3D"
                },
                PluginParameter {
                    name: "mapping.appid"
                    value: "ETjZnV1eZZ5o0JmN320V"
                }
            ]
        }
        mapType: Map.StreetMap
        connectivityMode: Map.HybridMode
        center: Coordinate {
            latitude: defaultLatitude
            longitude:defaultLongitude
        }
        property alias scenter: tform.origin
        property alias getSkale: tform.xScale
        function setSkale(v) {
            tform.xScale = v
            tform.yScale = v
        }
        transform: Scale{
            id: tform
        }
    }

    function panToCoordinate(coordinate) {
        panAnimation.latitude = coordinate.latitude;
        panAnimation.longitude = coordinate.longitude;
        panAnimation.restart();
    }

    function panToLatLong(latitude,longitude) {
        panAnimation.latitude = latitude;
        panAnimation.longitude = longitude;
        panAnimation.restart();
    }

    ParallelAnimation {
        id: panAnimation

        property real latitude
        property real longitude

        PropertyAnimation {
            target: map
            property: "center.latitude"
            to: panAnimation.latitude
            easing.type: Easing.InOutCubic
            duration: 1000
        }

        PropertyAnimation {
            target: map
            property: "center.longitude"
            to: panAnimation.longitude
            easing.type: Easing.InOutCubic
            duration: 1000
        }
    }

    PinchArea {
        id: pincharea
        anchors.fill: parent
        property double initScale
        property double p1toC_X
        property double p1toC_Y
        property double contentInitX
        property double contentInitY
        onPinchStarted: {
            initScale = map.getSkale
            p1toC_X = (pinch.center.x-map.size.width)
            p1toC_Y = (pinch.center.y-map.size.height)
            contentInitX = mapFlickable.contentX
            contentInitY = mapFlickable.contentY
        }
        onPinchFinished: {
            mapFlickable.updateViewPort()
        }
        onPinchUpdated: {
            var contentDriftX = ((1-pinch.scale)*p1toC_X)
            var contentDriftY = ((1-pinch.scale)*p1toC_Y)
            //pinch.center.(x|y) drifts from to content, term in parenthesis offsets this back
            //startCenter does not drift.
            var tCenterDriftX = (pinch.center.x-(mapFlickable.contentX-contentInitX) - pinch.startCenter.x)
            var tCenterDriftY = (pinch.center.y-(mapFlickable.contentY-contentInitY) - pinch.startCenter.y)
            //test all two!
            mapFlickable.contentX = contentInitX-contentDriftX-tCenterDriftX
            mapFlickable.contentY = contentInitY-contentDriftY-tCenterDriftY
            if(initScale*pinch.scale <= 0.75 && map.zoomLevel > 2) {
                map.zoomLevel -= 1
                map.setSkale(1.5)
                initScale = map.getSkale/pinch.scale
            } else if(initScale*pinch.scale >= 1.5 && map.zoomLevel < 18) {
                map.zoomLevel += 1
                map.setSkale(0.75)
                initScale = map.getSkale/pinch.scale
            } else {
                if(! ((map.zoomLevel == 18 && (initScale*pinch.scale) > 2.0)
                      || (map.zoomLevel == 2 && (initScale*pinch.scale) < 0.85))) {
                    map.setSkale(initScale*pinch.scale)
                }
            }
        }
    }

//    MouseArea {
//        anchors.fill: parent
//        onClicked: {
//            panToCoordinate(map.toCoordinate(Qt.point(mouseX-map.pos.x,mouseY-map.pos.y)))
//        }
//    }
}
